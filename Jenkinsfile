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
    }
}
