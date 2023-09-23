pipeline {
    agent {
        node {
            label 'ansible01'
        }
    }
//    environment {
//        image_tag = $image_build
//    }
    stages {
        stage('fetch latest code from git') {
            steps {
              git branch: 'main', url: 'https://github.com/pranavmurali1994/zenda.git'
            }
        }
        stage('Build and push docker image'){
            steps {
                script {
                    def dockerfilePath = '/opt/build/workspace/zenda_test/Dockerfile/'
                    sh "docker build -t pranavmurali1994/nodejs:$image_build -f ${dockerfilePath}Dockerfile ${dockerfilePath} "
                    sh "docker push pranavmurali1994/nodejs:$image_build"
                }
                
            }
        }
    }
}
