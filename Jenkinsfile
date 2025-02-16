pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-token')
        IMAGE_NAME = "ssanchez04/ci-jenkins"
        DEPLOYMENT_REPO = "https://github.com/S-Sanchez04/CI-K8s-Manifests.git"  // Repositorio de YAMLs
        DEPLOYMENT_PATH = "/tmp/k8s-manifests"
        DEPLOYMENT_FILE = "api-deployment.yaml"
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                git branch: 'main', url: 'https://github.com/S-Sanchez04/CI-Jenkins.git'
            }
        }

        stage('Get Latest Tag') {
            steps {
                script {
                    def latestTag = sh(script: '''
                        curl -s "https://hub.docker.com/v2/repositories/ssanchez04/ci-jenkins/tags/?page_size=100" | jq -r ".results | sort_by(.name) | .[-1].name"
                    ''', returnStdout: true).trim()

                    def newTag
                    if (latestTag =~ /^\d+\.\d+$/) {  
                        def parts = latestTag.split("\\.")
                        def major = parts[0].toInteger()
                        def minor = parts[1].toInteger() + 1
                        newTag = "${major}.${minor}"
                    } else {
                        newTag = "1.1"  
                    }

                    env.NEW_TAG = newTag
                    echo "Nuevo tag: ${env.NEW_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${env.NEW_TAG} ."
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-token', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "docker push ${IMAGE_NAME}:${env.NEW_TAG}"
                }
            }
        }

        stage('Update Deployment Manifest') {
            steps {
                script {
                    sh '''
                    rm -rf ${DEPLOYMENT_PATH}
                    git clone ${DEPLOYMENT_REPO} ${DEPLOYMENT_PATH}
                    '''

                    sh "sed -i 's|ssanchez04/ci-jenkins:[^ ]*|ssanchez04/ci-jenkins:${env.NEW_TAG}|g' ${DEPLOYMENT_PATH}/${DEPLOYMENT_FILE}"
                    cat "${DEPLOYMENT_PATH}/${DEPLOYMENT_FILE}"

                    // Hacer commit y push de los cambios
                    dir("${DEPLOYMENT_PATH}") {
                        sh '''
                        git add -A
                        git commit --allow-empty -m 'Update image tag to ${env.NEW_TAG}'
                        git push origin main
                        '''
                    }
                }
            }
        }

       
    }
}
