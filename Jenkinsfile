pipeline {
    agent any

    environment {
        DOCKER_HUB_ID = "abhiviz"
        IMAGE_NAME    = "quote-of-the-day"
    }

    stages {
        // STAGE 1: Build the Docker image from our Dockerfile
        stage('Build Docker Image') {
            steps {
                echo "Building the Docker image..."
                // Build the image and tag it with our Docker Hub ID, image name, and the unique build number
                sh "docker build -t ${DOCKER_HUB_ID}/${IMAGE_NAME}:${env.BUILD_NUMBER} ."
            }
        }

        // STAGE 2: Push the new image to the Docker Hub registry
        stage('Push to Docker Hub') {
            steps {
                echo "Pushing the Docker image..."
                // Use the 'dockerhub-credentials' we stored in Jenkins to securely log in
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                    sh "docker push ${DOCKER_HUB_ID}/${IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        // STAGE 3: Deploy the new image to our Kubernetes Cluster
        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying to Kubernetes..."
                script {
                    // THE MAGIC STEP: Use 'sed' to replace the placeholder in our deployment file
                    // with the actual, full image name we just built and pushed.
                    sh "sed -i 's|IMAGE_PLACEHOLDER|${DOCKER_HUB_ID}/${IMAGE_NAME}:${env.BUILD_NUMBER}|g' k8s/deployment.yaml"

                    // Now, apply the updated deployment and service files to the cluster
                    sh "kubectl apply -f k8s/deployment.yaml"
                    sh "kubectl apply -f k8s/service.yaml"
                }
            }
        }
    }
}