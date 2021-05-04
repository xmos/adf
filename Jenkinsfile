@Library('xmos_jenkins_shared_library@v0.14.2') _

getApproval()

pipeline {
    agent {
        dockerfile {
        }
    }

    parameters { // Available to modify on the job page within Jenkins if starting a build
        string( // use to try different tools versions
            name: 'TOOLS_VERSION',
            defaultValue: '15.0.5',
            description: 'The tools version to build with (check /projects/tools/ReleasesTools/)'
        )
        booleanParam( // use to check results of rolling all conda deps forward
            name: 'UPDATE_ALL',
            defaultValue: false,
            description: 'Update all conda packages before building'
        )
    }

    options { // plenty of things could go here
        //buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }

    stages {
        stage("Setup") {
            // Clone and install build dependencies
            steps {
                // clean auto default checkout
                sh "rm -rf *"
                // clone
                checkout([
                    $class: 'GitSCM',
                    branches: scm.branches,
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [[$class: 'SubmoduleOption',
                                  threads: 8,
                                  timeout: 20,
                                  shallow: true,
                                  parentCredentials: true,
                                  recursiveSubmodules: true],
                                 [$class: 'CleanCheckout']],
                    userRemoteConfigs: [[credentialsId: 'xmos-bot',
                                         url: 'git@github.com:xmos/ai_deployment_framework']]
                ])
                // create venv and install pip packages
                sh "conda env create -q -p ./adf_venv -f environment.yml"
                sh """. activate ./adf_venv &&
                      pip install -e "./xcore_interpreters[test]"
                """
                // Install xmos tools version
                sh "/XMOS/get_tools.py " + params.TOOLS_VERSION
            }
        }
        stage("Update all packages") {
            // Roll all conda packages forward beyond their pinned versions
            when { expression { return params.UPDATE_ALL } }
            steps {
                sh "conda update --all -y -q -p adf_venv"
            }
        }
        stage("Build") {
            steps {
                // below is how we can activate the tools, NOTE: xTIMEcomposer -> XTC at tools 15.0.5
                // sh """. /XMOS/tools/${params.TOOLS_VERSION}/XMOS/XTC/${params.TOOLS_VERSION}/SetEnv && //
                sh """. /XMOS/tools/${params.TOOLS_VERSION}/XMOS/XTC/${params.TOOLS_VERSION}/SetEnv &&
                      . activate ./adf_venv &&
                      make build CLOBBER_FLAG='-c'
                """
                sh ". activate ./adf_venv && make xcore_interpreters_dist"
            }
        }
        stage("Test") {
            steps {
                sh ". activate ./adf_venv && make test"
                // Any call to pytest can be given the "--junitxml SOMETHING_junit.xml" option
                // This step collects these files for display in Jenkins UI
                junit "**/*_junit.xml"
            }
        }
    }
    post {
        cleanup {
            cleanWs()
        }
    }
}
