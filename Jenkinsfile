pipeline {
    agent {
        node {
            label 'ansible01'
        }
    }
    stages {
        stage('mkdir') {
            steps {
                sh 'mkdir /home/jenkins'
            }
        }
    }
}
