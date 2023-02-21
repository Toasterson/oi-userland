// OpenIndiana userland Jenkinsfile, (c) 2023 Till Wegmueller <toasterson@gmail.com>

pipeline {
    options {
        // set a timeout of 60 hours for this pipeline
        timeout(time: 60, unit: 'HOURS')
    }
    agent {
      node {
        label 'userland'
      }
    }
    triggers {
        pollSCM('H/15 * * * *')
    }
    stages {
        stage('setup stage') {
            steps {
        		sh 'gmake setup'
            }
        }

        stage('build userland packages') {
            steps {
            	sh 'gmake publish -k'
            }
        }

    }
}

