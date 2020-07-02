pipeline {
  agent any 
	environment {
	docker_tag=getDockerTag()
	 USERNAME = credentials('DOCKER_USERNAME')
         PASSWORD = credentials('DOCKER_PASSWORD')
	}
  tools {
    maven 'Maven'
  }
  stages {
    stage ('Initialize') {
      steps {
        sh '''
                    echo "PATH = ${PATH}"
                    echo "M2_HOME = ${M2_HOME}"
            ''' 
      }
    }
    stage ('Check-Git-Secrets') {
	steps {
		sh 'rm trufflelog || true'
		sh 'docker run gesellix/trufflehog --json --regex https://github.com/save2017/Anusha.git > trufflehog'
		sh 'cat trufflehog'
		}
			}
    
    stage('Source-Composition-analysis'){
	steps{
		sh 'mvn clean'
		sh 'rm owasp* || true'
		sh 'wget "https://raw.githubusercontent.com/save2017/Anusha/master/owasp-dependency-check.sh" '
		sh 'chmod +x owasp-dependency-check.sh'
		sh 'bash owasp-dependency-check.sh'
		}
	  }

    stage ('SAST') {
      steps {
        withSonarQubeEnv('Sonarqube') {
          sh 'mvn sonar:sonar'
          sh 'cat target/sonar/report-task.txt'
        }
      }
    }
	  
    stage ('Build'){
      steps {
     sh 'mvn clean package'
    }
    } 
    
       stage ('Deploy-To-Tomcat') {
            steps {
           sshagent(['tomcat']) {
                sh 'scp -o StrictHostKeyChecking=no target/*.war root@192.168.127.193:/prod/apache-tomcat-8.5.54/webapps/webapp.war'
              }      
           }       
    }
  
       stage ('Building Docker images') {
            steps {
           	    sh 'rm /opt/docker/*.war'
		    sh 'docker rmi -f webappimage:latest'
		    sh 'cp target/*.war /opt/docker/webapp.war'  
		    sh 'docker build --tag webappimage:$docker_tag /opt/docker/.'    
           }       
    }
	  
	        stage ('Pushing to dockerhub') {
            steps {
           	    sh 'docker login -u ${USERNAME} -p ${PASSWORD}'
		    sh 'docker tag webappimage:$docker_tag jackheal445/webappimage:$docker_tag'
		    sh 'docker push jackheal445/webappimage:$docker_tag'    
           }       
    }
	  
	  stage('k8s'){
		  steps{
		    sh 'chmod +x changetag.sh'
	            sh './changetag.sh ${docker_tag}'
	            sshagent(['kubernetes']){
		     sh 'scp -o StrictHostKeyChecking=no services.yml kubapppod.yml root@192.168.127.227:/root/'
			    script{
				    try{
					    sh 'ssh root@192.168.127.227 kubectl apply -f .'
				    }catch(error){
				    	    sh 'ssh root@192.168.127.227 kubectl create -f .'
				    }
			    }
			  
			  }
		  }
	  }
     
	  
    stage ('DAST') {
      steps {
        sshagent(['ZAP']) {
         sh 'ssh -o  StrictHostKeyChecking=no root@192.168.127.228 "docker run -t owasp/zap2docker-stable zap-baseline.py -t http://192.168.127.193:8080/webapp/" || true'
        }
      }
    }
	  
  }
}

def getDockerTag(){
	def tag=sh script: 'git rev-parse HEAD', returnStdout: true
	return tag
}
