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

                    sh """
                        awk -v new_tag="${env.NEW_TAG}" '
                            /image: ssanchez04\\/ci-jenkins:/ {sub(/ssanchez04\\/ci-jenkins:[0-9]+\\.[0-9]+/, "ssanchez04/ci-jenkins:" new_tag)}
                            {print}
                        ' ${DEPLOYMENT_PATH}/${DEPLOYMENT_FILE} > temp.yaml && mv temp.yaml ${DEPLOYMENT_PATH}/${DEPLOYMENT_FILE}
                        cat ${DEPLOYMENT_PATH}/${DEPLOYMENT_FILE}
                    """


                    // Moverse al directorio clonado para configurar Git
                    dir("${DEPLOYMENT_PATH}") {
                        withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                            sh """
                            git remote set-url origin https://${GITHUB_TOKEN}@github.com/S-Sanchez04/CI-K8s-Manifests.git
                            git add -A
                            git commit --allow-empty -m "Update image tag to ${env.NEW_TAG}"
                            git push origin main
                            """
                        }
                    }
                }
            }
        }


       
    }
}
