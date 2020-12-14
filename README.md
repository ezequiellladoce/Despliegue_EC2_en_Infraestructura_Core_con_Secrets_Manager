# DESPLIEGE DE UNA INSTANCIA EC2 EN INFRAESTRUCTURA YA CREADA MEDIANTE EL USO DE BACKEND EN S3 CON TERRAFORM 

El objetivo de este repositorio es mostrar como desplegar automáticamente desde terraform una instancia de AWS dentro de una infraestuctura core ya creada mediante el uso de la funcion Backend de terraform almacenada en un S3. 


## Pre-requisitos 📋

- TERRAFORM .12 o superior
- AWS CLI
- CUENTA FREE TIER AWS 

## Comenzando 🚀

### Descripción del repositorio:

En la carpeta Deploy_Core tendremos el código para crear la infraestuctura Core, alli monatremos:

 - Infraestrucura basica aws (VPC - Security Groups - Internet Gateway - Subnet - Route Table)
 - Creamos desde terraform la Private Key
 - Almacenamos la clave  creada en aws secretsmanager
 - Creamos los outputs de los parametros Subnet ID y Security Group ID
 - Guardamos con la función Backend en S3 la informacion de la infraestuctura creada.
 
 En La carpeta Deploy_Ec2, alli montaremos:
 
 - El codigo para crear la Instancia EC2 con la información almacenada en el Backed de S3.
 - Creamos el output Public Ip y lo almacenamos en el Backend de la instancia
 
 En La carpeta Public_ip_from_backend, alli montaremos:
 
 - El codigo hace un output de la ip publica de la instancia creada desde el backend, con la ip Publica y la clave pem almacenada en el Secret Manager podremos    configurar la instancia mediante Ansible.

### Descripción del Código:

#### AWS Secret Manager

##### Infraestructura Core

Con el recurso aws_secretsmanager_secret Creamos en la infraestructura core el Secrets en el servicio de AWS Secret Manager. El código es el Siguinte:

''' 
resource "aws_secretsmanager_secret" "secret_key" {
  name = var.Secret_Key
  description = "Name of the secret key"
  tags = {
    Name = "EC2-Key-4"
  }
}
'''

Con el recurso aws_secretsmanager_secret_version cargamos la clave creada por el recurso tls_private_key. El código es el Siguinte:

'''
resource "aws_secretsmanager_secret_version" "secret_priv" {
  secret_id     = aws_secretsmanager_secret.secret_key.id
  secret_string = tls_private_key.priv_key.private_key_pem
}
'''










### Preparamos el ambiente:

1) Instalalamos Terrafom https://learn.hashicorp.com/tutorials/terraform/install-cli
2) Creamos cuenta free tier en AWS  https://aws.amazon.com/
3) Instalamos AWS CLI https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
4) Creamos usario AWS en la seccion IAM con acceso Programatico y permisos de administrador https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html   
5) Configuramos el AWS CLI https://docs.aws.amazon.com/polly/latest/dg/setup-aws-cli.html
6) Creamos un Buket S3 con las carpetas tfbkcore y tfbkec2

### Decripción del repositorio:

En la carpeta Deploy_Core tendremos el código para crear la infraestuctura Core, alli monatremos:

 - Infraestrucura basica aws (VPC - Security Groups - Internet Gateway - Subnet - Route Table)
 - Creamos desde terraform la Private Key
 - Almacenamos la clave  creada en aws secretsmanager
 - Creamos los outputs de los parametros Subnet ID y Security Group ID
 - Guardamos con la función Backend en S3 la informacion de la infraestuctura creada.
 
 En La carpeta Deploy_Ec2, alli montaremos:
 
 - El codigo para crear la Instancia EC2 con la información almacenada en el Backed de S3.
 - Creamos el output Public Ip y lo almacenamos en el Backend de la instancia
 
 En La carpeta Public_ip_from_backend, alli montaremos:
 
 - El codigo hace un output de la ip publica de la instancia creada desde el backend, con la ip Publica y la clave pem almacenada en el Secret Manager podremos    configurar la instancia mediante Ansible.
  
## Despliegue 📦

### Consideraciones iniciales

### Ejecutamos el despliegue

Clonamos el repositorio en la carpeta e ingresamos 


2) Ejecutamos terraform int, para que terraform baje los plugins necesarios
3) Ejecutamos terraform plan
4) Ejecutamos terrafom apply para que realice el despliegue.
5) Vamos a muestra cuenta de AWS para verificar que se haya realizado el despliegue
6) Nos conectamos a nuestra instancia y corremos el comando sudo docker ps -a para verificar que el container con la imagen Nginx este corriendo. 
7) Copiamos la ip publica de nuestra instancia y ponemos en nuestro navegador, se mostrar la página de inicio de Ngnix.

## Información de referencia 🛠️

