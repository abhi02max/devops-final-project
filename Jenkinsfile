pipeline {
    agent any

    environment {
        DOCKER_HUB_ID = "abhiviz" // <-- CHANGE THIS
        IMAGE_NAME    = "quote-of-the-day"
    }

    stages {
        // NEW STAGE: Setup monitoring tools using Ansible
        stage('Setup Monitoring') {
            steps {
                echo "Setting up Prometheus and Grafana using Ansible..."
                // We need to install the Ansible Docker module dependency first
                sh "ansible-galaxy collection install community.docker"
                // Run the playbook to install our tools
                sh "ansible-playbook setup_monitoring.yaml"
            }
        }

        // STAGE 2: Build the Docker image
        stage('Build Docker Image') {
            steps {
                echo "Building the Docker image..."
                sh "docker build -t ${DOCKER_HUB_ID}/${IMAGE_NAME}:${env.BUILD_NUMBER} ."
            }
        }

        // STAGE 3: Push to Docker Hub
        stage('Push to Docker Hub') {
            steps {
                echo "Pushing the Docker image..."
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                    sh "docker push ${DOCKER_HUB_ID}/${IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        // STAGE 4: Deploy to Kubernetes
        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying to Kubernetes..."
                script {
                    sh "sed -i 's|IMAGE_PLACEHOLDER|${DOCKER_HUB_ID}/${IMAGE_NAME}:${env.BUILD_NUMBER}|g' k8s/deployment.yaml"
                    sh "kubectl apply -f k8s/deployment.yaml"
                    sh "kubectl apply -f k8s/service.yaml"
                }
            }
        }
    }
}