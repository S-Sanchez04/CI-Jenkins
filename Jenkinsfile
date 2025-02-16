pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-token')
        IMAGE_NAME = "ssanchez04/ci-jenkins"
    }


    


    stages {

        stage('Verificar Credenciales') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-token', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat """
                    echo DOCKER_USER: %DOCKER_USER%
                    echo DOCKER_PASS: %DOCKER_PASS%
                    """
                }
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-token', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat """
                    set DOCKER_CLI_ACI=0
                    echo Logging in as %DOCKER_USER%
                    docker login -u %DOCKER_USER% -p %DOCKER_PASS%
                    """
                }
            }
        }


        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/S-Sanchez04/CI-Jenkins.git'
            }
        }

        stage('Get Latest Tag') {
            steps {
                script {
                    def latestTag = bat(script: '''@echo off
curl -s "https://hub.docker.com/v2/repositories/ssanchez04/ci-jenkins/tags/?page_size=100" > tags.json
C:/ProgramData/chocolatey/bin/jq.exe -r ".results | sort_by(.name) | .[-1].name" tags.json
                    ''', returnStdout: true).trim()

                    def newTag = latestTag.isNumber() ? (latestTag.toInteger() + 1) : 1  
                    env.NEW_TAG = newTag.toString()
                    echo "Nuevo tag: ${env.NEW_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    bat "docker build -t ${IMAGE_NAME}:${env.NEW_TAG} ."
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    bat "echo ${DOCKERHUB_CREDENTIALS} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
                }
            }
        }

        stage('Push Docker Image') {  // Corregido nombre de la etapa
            steps {
                script {
                    bat "docker push ${IMAGE_NAME}:${env.NEW_TAG}"
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    bat "docker rmi ${IMAGE_NAME}:${env.NEW_TAG}"
                }
            }
        }
    }
}
