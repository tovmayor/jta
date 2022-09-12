pipeline {
    agent any
    tools {
       terraform 'terraform'
    }
    stages {
        stage('Git checkout') {
           steps{
                git branch: 'main', credentialsId: '4377acaf-03d8-44f5-84c4-0836c40569bd', url: 'https://github.com/tovmayor/jta.git'
            }
        }
        stage('terraform Init') {
            steps{
                sh 'terraform init -plugin-dir=/home/andrew/jta/.terraform/providers/'
            }
        }
        stage('terraform apply') {
            steps{
                sh 'terraform apply --auto-approve'
            }
        }
        stage('build inventory for ansible') {
            steps{
                sh 'echo -e "[build]\n"$(terraform output -raw build_ip)" ansible_user=ubuntu\n" > inv4ansible'
            }
        }
        stage('Where am I') {
            steps{
                sh 'pwd && ls -la && cat inv4ansible'
            }
        }    
       
        stage('ansible comes') {
            steps{
//                sh 'ansible-playbook -i inv4ansible playbook.yml --private-key'
                ansiblePlaybook playbook: 'playbook.yml', inventory: 'inv4ansible', credentialsId: '2eadfdda-cc98-42e0-bf1b-43c856dcf1af'
            }
        }

    }
}
