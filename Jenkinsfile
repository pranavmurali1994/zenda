pipeline {
    agent {
        node {
            label 'ansible01'
        }
    }
    stages {
        stage('fetch latest code from git') {
            steps {
              git branch: 'main', url: 'https://github.com/pranavmurali1994/zenda.git'
            }
        }
        stage('Build and push docker image'){
            steps {
                script {
                    def dockerfilePath = '/opt/build/workspace/zenda/Dockerfile/'
                    sh "docker build -t pranavmurali1994/nodejs:$image_build -f ${dockerfilePath}Dockerfile ${dockerfilePath} "
                    sh "docker push pranavmurali1994/nodejs:$image_build"
                }
                
            }
        }
        stage('Deploying application using Ansible') {
            steps {
                ansiblePlaybook extras: '-e image_id=$image_build',
                inventory: '/opt/build/workspace/zenda/ansible-k8s/host.yml', 
                playbook: '/opt/build/workspace/zenda/ansible-k8s/tasks/main.yml'
            }
        }
    }
}
