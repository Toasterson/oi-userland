// OpenIndiana encumbered Jenkinsfile, (c) 2023 Till Wegmueller <toasterson@gmail.com>

pipeline {
    options {
        // set a timeout of 600 minutes for this pipeline
        timeout(time: 600, unit: 'MINUTES')
    }
    agent {
      node {
        label 'encumbered'
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

        stage('build encumbered packages') {
            steps {
                dir('components/encumbered') {
                    sh 'gmake publish'
                }
            }
        }

    }
}

