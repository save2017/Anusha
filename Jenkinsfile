pipeline {
  agent any 
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

     stage ('DAST') {
      steps {
        sshagent(['zap']) {
         sh 'ssh -o  StrictHostKeyChecking=no root@192.168.127.228 "docker run -t owasp/zap2docker-stable zap-baseline.py -t http://192.168.127.193:8080/webapp/" || true'
        }
      }
    }
	  
  }
}
