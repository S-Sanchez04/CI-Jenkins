pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-token')
        IMAGE_NAME = "ssanchez04/ci-jenkins"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/S-Sanchez04/CI-Jenkins.git'
            }
        }

        stage('Get Latest Tag') {
            steps {
                script {
                    def latestTag = bat(script: '@echo off && curl -s "https://hub.docker.com/v2/repositories/ssanchez04/ci-jenkins/tags/?page_size=100" | jq -r ".results | sort_by(.name) | .[-1].name"', returnStdout: true).trim()
           
                    
                    def newTag = latestTag.isInteger() ? (latestTag.toInteger() + 1) : 1  
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
                    bat "echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
                }
            }
        }

        stage('Pubat Docker Image') {
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
