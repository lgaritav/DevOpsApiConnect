def git_revision = ""
def image
def appName
def version
def namespace
def template
pipeline {
  agent{
      label 'docker'
  }
  stages {
    stage('Prepare'){
      steps{
        script{
          appName = sh(
            script: "cat appName",
            returnStdout: true
          )
          version = sh(
            script: "cat version",
            returnStdout: true
          )
          template = sh(
            script: "cat oc/template.json",
            returnStdout: true
          )
          namespace = "oc-jenkins-tests"
        }
        echo "Image: ${appName}:${version}"
      }
    }
    stage('Login'){
      steps{
        sh 'docker login -u jenkins -p $(cat /var/run/secrets/kubernetes.io/serviceaccount/token) 172.30.1.1:5000/oc-jenkins-tests'
      }
    }
    stage('Build'){
      steps {
        script{
          image = docker.build("172.30.1.1:5000/${namespace}/${appName}:${version}")
        }
      }
    }
    stage('Push'){
        steps{
          script{
            image.push()
          }
        }
    }
    stage('Deploy'){
      agent { label 'master' }
      steps{
        script{
          openshift.withCluster(){
            openshift.withProject(){
	          def deployment = openshift.selector('dc',[template: 'ace', app: appName])
              openshift.tag("${appName}:${version}","${appName}:latest")
              if(!deployment.exists()){             
              	def model = openshift.process(template, "-p", "APPLICATION_NAME=${appName}", "-p", "PROJECT=${namespace}", "-p", "IMAGE=${appName}:latest")
              	openshift.create(model)
              	deployment = openshift.selector('dc',[template: 'ace', app: appName])
              }
              deployment.rollout().latest()
              def latestVersion = deployment.object().status.latestVersion
              def rc = openshift.selector('rc',"${appName}-${latestVersion}")
              timeout(time:1, unit: 'MINUTES'){
                rc.untilEach(1){
                  def rcMap = it.object()
                  return (rcMap.status.replicas.equals(rcMap.status.readyReplicas))
                }
              }
            }
          }
        }
      }
    } 
  }
}
