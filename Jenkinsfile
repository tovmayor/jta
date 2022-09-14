pipeline {
    agent any
    tools {
       terraform 'terraform'
    }
    environment {
        BUILD_IP = 't-build'
        PROD_IP = 't-prod'
        DOCKER_REPO = 'tovmayor/mywebdckr'
    }

    stages {
        stage('Git checkout') {
           steps{
                git branch: 'main', credentialsId: '4377acaf-03d8-44f5-84c4-0836c40569bd', url: 'https://github.com/tovmayor/jta.git'
            }
        }
        stage('terraforming instances') {
            steps{
                sh 'terraform init -plugin-dir=/home/andrew/jta/.terraform/providers/'
                sh 'terraform apply --auto-approve'
                script {
                  BUILD_IP = sh(returnStdout: true, script: 'terraform output -raw build_ip').trim()
                  PROD_IP = sh(returnStdout: true, script: 'terraform output -raw prod_ip').trim()
                }
                echo "!!!! ${BUILD_IP} !!!!!\n!!!! ${PROD_IP} !!!!!" //ВЫВОДИТ IP, всё норм
                sh 'echo "???? ${BUILD_IP} ????\n???? ${PROD_IP} ????"'

                sh 'echo "[build]\n${BUILD_IP} ansible_user=ubuntu\n[prod]\n${PROD_IP} ansible_user=ubuntu\n" > inv4ansible'

            }
        }    
        stage('Where am I') {
            steps{
                sh 'pwd && ls -la && cat inv4ansible'
            }
        }    
        stage('ansible comes') {
            steps{
                sh 'ssh-keyscan -H ${BUILD_IP} >> ~/.ssh/known_hosts'
                sh 'ansible-playbook -i inv4ansible playbook.yml --private-key /var/lib/jenkins/.ssh/id_rsa --ssh-common-args="-o StrictHostKeyChecking=no"'
            }
        }
        stage ('Build package on build-instance') {
            steps {
                sh '''ssh ubuntu@${BUILD_IP} << EOF
                sudo mvn -f /src/build/myboxfuse package
                sudo cp /src/build/myboxfuse/target/*.war /src/build/
                << EOF'''
            }
        }        
        stage ('Copy Dockerfile to build instance & Build docker image') {
            steps {
                sh 'cat Dockerfile | ssh ubuntu@${BUILD_IP} "sudo tee -a /src/build/Dockerfile"'
                sh '''ssh ubuntu@${BUILD_IP} << EOF
                cd /src/build/
                sudo docker build -t ${DOCKER_REPO}:jta-prod .
                sudo docker login -u tovmayor -p Ghbrjkbcm76
                sudo docker push ${DOCKER_REPO}:jta-prod
                << EOF'''
            }
        }        
        stage ('Run Docker image on prod instance') {
            steps {
                sh '''ssh ubuntu@${PROD_IP} << EOF
                sudo docker run -p 8080:8080 -d ${DOCKER_REPO}:jta-prod
                << EOF'''
            }
        }        
    }
}
