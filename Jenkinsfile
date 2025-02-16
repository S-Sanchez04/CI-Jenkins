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
                        curl -s "https://hub.docker.com/v2/repositories/ssanchez04/ci-jenkins/tags/?page_size=100" | \
                        jq -r '[.results[].name | select(test("^[0-9]+\\.[0-9]+$")) | map(tonumber)] | sort | last | join(".")'
                       ''', returnStdout: true).trim()

                    def newTag
                    if (latestTag == "" || !(latestTag =~ /^\d+\.\d+$/)) {
                        newTag = "1.1"  // Si no encuentra tags válidos, empieza en 1.1
                    } else {
                        def parts = latestTag.split("\\.")
                        def major = parts[0].toInteger()
                        def minor = parts[1].toInteger() + 1
                        newTag = "${major}.${minor}"
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
                        set -e
                        awk -v new_tag=${env.NEW_TAG} '
                            /image: ssanchez04\\/ci-jenkins:/ {sub(/ssanchez04\\/ci-jenkins:[0-9]+\\.[0-9]+/, "ssanchez04/ci-jenkins:" new_tag)}
                            {print}
                        ' /tmp/k8s-manifests/api-deployment.yaml > /tmp/k8s-manifests/api-deployment.tmp
                        mv /tmp/k8s-manifests/api-deployment.tmp /tmp/k8s-manifests/api-deployment.yaml
                    """




                    // Moverse al directorio clonado para configurar Git
                    dir("${DEPLOYMENT_PATH}") {
                        withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                            sh """
                            git remote set-url origin https://${GITHUB_TOKEN}@github.com/S-Sanchez04/CI-K8s-Manifests.git
                            git pull --rebase origin main
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
