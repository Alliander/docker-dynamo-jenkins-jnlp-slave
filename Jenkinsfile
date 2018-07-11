#!groovy
@Library('dynamo-workflow-libs@docker-only') _

dockerImageName = 'jenkins-jnlp-slave'
gitRepoName = 'docker-dynamo-jenkins-jnlp-slave.git'

pipeline {
    agent any
    stages {
        stage('Docker') {
            steps {
                script {
                	if (isReleasableBranch(env.BRANCH_NAME)) {
                        version = "1.0.${currentBuild.number}"
                    } else {
                    	version = "1.0.${currentBuild.number}-${env.BRANCH_NAME.replaceAll("feature/", "").replaceAll("[^a-zA-Z0-9]", ".")}"
                    }

                    echo "Version ${version}"
                    dockerBuildAndPush("usefdynamo/$dockerImageName", version, isReleasableBranch(env.BRANCH_NAME))
                }
            }
        }
    }
}

def isReleasableBranch(String branch) {
    return branch == "master"
}
