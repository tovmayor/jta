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
        stage('Where am I') {
            steps{
                sh 'pwd && ls -la && whoami'
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
    }
}

withCredentials([string(credentialsId: '2eadfdda-cc98-42e0-bf1b-43c856dcf1af', variable: 'AWS_ACCESS_KEY_ID'), 
                       string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
        