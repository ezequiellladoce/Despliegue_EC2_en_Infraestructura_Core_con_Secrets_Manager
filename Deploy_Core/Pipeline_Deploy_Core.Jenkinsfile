pipeline {
    agent any 
    environment {
        AWS_DEFAULT_REGION = 'eu-west-1' 
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }
    options {
      disableConcurrentBuilds()
      parallelsAlwaysFailFast()
      timestamps()
      withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding', 
            credentialsId: 'awskey', 
            accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
            ]]) 
    }
parameters { 
    choice(name: 'ACCION', choices: ['', 'plan-apply', 'destroy'], description: 'Seleccione la Accion')
}
    stages{ 
        stage('Terraform Plan-Apply / Destroy ----') {
            steps {
             script{  
                    if (params.ACCION == "destroy"){
                            sh ' echo "llego" + params.ACCION'   
                            sh 'terraform destroy -auto-approve'
                        } 
                    else {
                            cleanWs()
                            sh 'env'
                            checkout([$class: 'GitSCM', 
                            branches: [[name: '*/main']], 
                            doGenerateSubmoduleConfigurations: false, 
                            extensions: [[$class: 'CleanCheckout']], 
                            submoduleCfg: [], 
                            userRemoteConfigs: [
                            [url: 'https://github.com/ezequiellladoce/Jenkins_2.2.git', credentialsId: '']
                            ]])
                            sh 'pwd' 
                            sh 'ls -l'
                            sh 'cd Deploy_Core'
                            sh 'pwd' 
                            sh 'terraform --version'
                            sh 'terraform init'
                            sh ' echo  "llego" + params.ACCION' 
                            sh 'terraform plan'
                            sh 'terraform apply -auto-approve'  
                        }
                }  // if
            } //steps
        }  //stage
    }  // stages
}//pipeline