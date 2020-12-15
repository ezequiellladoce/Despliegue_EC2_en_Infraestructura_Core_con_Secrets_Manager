# Despliegue de EC2 en Infraestructura Core con Secrets Manager 

El objetivo de este repositorio es compartir  como desplegar automatizar y securizar el despliegue de una infraestructura core (VPC - Security Groups - Internet Gateway - Subnet - Route Table) y una instancia EC2  pero focalizaremos en:

- La creación de secretos que almacenaremos en el Secret Manager y luego obtendremos en el automatismo para hacer uso del mismo.
- La creación desde terraform una instancia de AWS dentro de una infraestructura core ya creada mediante el uso de el recurso Terraform Backend almacenada en un S3. 

Recordemos que es vital estar alineados con las buenas practicas sobre todo a las de seguridad.

## Pre-requisitos 📋

- TERRAFORM .12 o superior
- AWS CLI
- CUENTA FREE TIER AWS 

## Comenzando 🚀

### Descripción del repositorio:

En la carpeta Deploy_Core tendremos el código para crear la infraestructura base, esta permitirá:

 - Crear la Infraestructura básica aws (VPC - Security Groups - Internet Gateway - Subnet - Route Table)
 - Crear desde terraform la clave mediante el recurso TLS Private Key
 - Almacenar la clave  creada en Aws Secrets Manager
 - Crear los outputs de los parámetros Subnet ID y Security Group ID
 - Guardar con la función Backend en S3 la información de la infraestructura creada.
 
 En La carpeta Deploy_Ec2 tendremos el código para crear la instancia EC2, este permitirá:
 
 - Crear la Instancia EC2 con la información almacenada en el Backed de S3.
 - Crear el output Public Ip y lo almacenamos en el Backend de la instancia.
 
 En La carpeta Public_ip_from_backend tendremos el código para obtener la ip pública de la instancia: 
 
 - El código hace un output de la ip pública de la instancia creada desde el backend del EC2, con la ip Publica y la clave pem almacenada en el Secret Manager podremos configurar la instancia mediante Ansible.

### Descripción del Código:

#### Infraestructura Core

##### AWS Secret Manager

Con el recurso aws_secretsmanager_secret Creamos el Secrets en el servicio de AWS Secret Manager. El código es el siguiente:

```
resource "aws_secretsmanager_secret" "secret_key" {
  name = var.Secret_Key
  description = "Name of the secret key"
  tags = {
    Name = "EC2-Key-4"
  }
}
```

Con el recurso aws_secretsmanager_secret_version cargamos la clave creada por el recurso tls_private_key. El código es el siguiente:

```
resource "aws_secretsmanager_secret_version" "secret_priv" {
  secret_id     = aws_secretsmanager_secret.secret_key.id
  secret_string = tls_private_key.priv_key.private_key_pem
}
```

##### Terrafom Backend

Con terraform Backend podremos almacenar la configuración de la infraestructura core creada y almacenarla en forma remota en un bucket S3.

```
terraform {
  backend "s3" {
    bucket = "tfbackup"
    key    = "tfbkcore/"
    region = "us-east-2"
  }
}
```

#### Deploy Ec2

##### Terraform remote state

El data Terraform remote state nos permite extraer los outputs grabados en el útltimo snapshot  del  remote backend. 

```
data "terraform_remote_state" "LTFS" {
  backend = "s3"
  config = {
      bucket = "tfbackup"
      key    = "tfbkcore/"
      region = "us-east-2"
  }
}
```
Con la información de los outputs del data Terraform remote tendremos la subnet id y el vpc security group ids para utilizarlos en la creación de la instancia. 

```
resource "aws_instance" "EC2-Deploy" {
  ami                         = "ami-03657b56516ab7912"
  instance_type               = "t2.micro"
  subnet_id                   = data.terraform_remote_state.LTFS.outputs.sb_id
  vpc_security_group_ids      = data.terraform_remote_state.LTFS.outputs.sg_id
  associate_public_ip_address = true
  key_name                    = "key_2"
  user_data = " ${file("Bash_install.sh")} "
  tags = {
    Name = "EC2-Deploy"
  }
}

```
Una vez creada la instancia, creamos el output de la ip pública y almacenanos la información en el terraform backend de la instancia.

```
output "public_ip" {
  value = aws_instance.EC2-Deploy.public_ip
}

terraform {
  backend "s3" {
    bucket = "tfbackup"
    key    = "tfbkec2/"
    region = "us-east-2"
  }
}

```
#### Public ip from backend

En este código simplemente usamos el outputs del data Terraform remote para obtener la ip publica de la instancia creada. 

```
data "terraform_remote_state" "LTFS" {
  backend = "s3"
  config = {
      bucket = "tfbackup"
      key    = "tfbkec2/"
      region = "us-east-2"
  }
}

output "pub_ip" {
  value = data.terraform_remote_state.LTFS.outputs.public_ip
}
```

## Despliegue 📦

### Preparamos el ambiente:

1) Instalamos Terrafom https://learn.hashicorp.com/tutorials/terraform/install-cli
2) Creamos cuenta free tier en AWS  https://aws.amazon.com/
3) Instalamos AWS CLI https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
4) Creamos usuario AWS en la sección IAM con acceso Programático y permisos de administrador https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html   
5) Configuramos el AWS CLI https://docs.aws.amazon.com/polly/latest/dg/setup-aws-cli.html
6) Creamos en un Buket S3 con versionado las carpetas tfbkcore y tfbkec2.

### Ejecutamos el despliegue

#### Despliegue de Infraestructura Core.

1) Clonamos el repositorio
2) Ingresamos en la carpeta Deploy_Core
3) Editamos el archivo main.tf y cambiamos el bucket en el terraform backend.
4) Ejecutamos terraform int, para que terraform baje los plugins necesarios
5) Ejecutamos terraform plan
6) Ejecutamos terrafom apply para que realice el despliegue.
7) Verificamos que realice los outputs.
8) Vamos a muestra cuenta de AWS para verificar que se haya realizado el despliegue
9) Vamos al AWS Secret Manager para verificar que creo el secret y lo cargo.

#### Despliege de la Instancia.

1) Ingresamos en la carpeta Deploy_Ec2
2) Editamos el archivo Deploy-EC2.tf y cambiamos el bucket en el terraform backend y en el data terraform remote state
3) Ejecutamos terraform int, para que terraform baje los plugins necesarios
4) Ejecutamos terraform plan
5) Ejecutamos terrafom apply para que realice el despliegue.
6) Verificamos que realice el output.
7) Vamos a muestra cuenta de AWS para verificar que se haya realizado el despliegue

#### Despliegue del código Public ip from backend 

1) Ingresamos en la carpeta Public_ip_from_backend
2) Editamos el archivo Public_ip_from_backend.tf y cambiamos el bucket en el data terraform remote state
3) Ejecutamos terraform int, para que terraform baje los plugins necesarios
4) Ejecutamos terraform plan
5) Ejecutamos terrafom apply para que realice el despliegue.
6) Verificamos que realice el output.
