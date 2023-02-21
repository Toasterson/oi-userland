// OpenIndiana illumos-gate Jenkinsfile, (c) 2023 Till Wegmueller <toasterson@gmail.com>

pipeline {
    options {
        // set a timeout of 600 minutes for this pipeline
        timeout(time: 600, unit: 'MINUTES')
    }
    agent {
      node {
        label 'illumos-gate'
      }
    }
    triggers {
        cron('@midnight')
    }
    stages {
        stage('setup stage') {
            steps {
		        sh 'gmake setup'
            }
        }

        stage('build illumos-gate') {
            steps {
                dir('components/openindiana/illumos-gate') {
                    sh 'gmake publish'
                }
            }
        }

    }
}

