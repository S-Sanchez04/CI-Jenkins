pipeline {
    agent any 

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github-token', url: 'https://github.com/S-Sanchez04/CI-Jenkins.git'
            }
        }
        stage('Build') {
            steps {
                echo 'Construyendo la aplicación...'
            }
        }
        stage('Test') {
            steps {
                echo 'Ejecutando pruebas...'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Desplegando la aplicación...'
            }
        }
    }
}
