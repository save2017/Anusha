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
  

stage ('DAST-Report') {
      steps {
        sshagent(['ZAP1']) {
         sh 'ssh -o  StrictHostKeyChecking=no madan@192.168.126.32 " zaproxy  -daemon -quickurl http://192.168.127.193:8080/webapp/ -quickout /path/to/report.xml" || true'
        }
	}
}
	  
  }
}
