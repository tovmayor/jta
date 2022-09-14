pipeline {
    agent any
    tools {
       terraform 'terraform'
    }
    environment {
        BUILD_IP = 't-build'
        PROD_IP = 't-prod'
        DOCKER_REPO = 'nexus_ip'
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
                sudo docker build -t ${DOCKER_REPO}/jta-prod .
//                sh 'docker push ${DOCKER_REPO}/jta-prod'
                << EOF'''
            }
        }        
        stage('removing cloned git repository for further cloning') {
            steps{
//                sh '''ssh ubuntu@${BUILD_IP} << EOF
//                sudo rm -rf /src/build/*
//                << EOF'''
            }
        }
    }
}
