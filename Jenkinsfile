pipeline {
    agent any
	environment {
        UUID uuid = UUID.randomUUID()
        }
	
	tools {
        maven 'maven' 
        }
	
        stages {    
        stage('GIT clone repo and creation of version.html') {
            steps {
               //clone repo
               git 'https://github.com/vishvaja0630/AutomationWithTerraform.git'
			  
	       //Creating version.html and writing randomUUID to it
	       sh script:'''
	       touch musicstore/src/main/webapp/version.html
	       '''
	       println uuid
	       writeFile file: "musicstore/src/main/webapp/version.html", text: uuid
               }
         }
	    
	stage('Build maven project'){
	       //cd to pom.xml
	       steps{
		   sh script:'''
		   cd musicstore
		   mvn -Dmaven.test.failure.ignore=true clean package
		   '''
	       }
	}
	    
	//Creating and running dockerisedtomcatcontainer using terraform   
	stage('Create and run containers using terraform'){
               steps{
	       //use credentials from jenkins with credentialId: vish_docker
	       withCredentials([usernamePassword(credentialsId: 'vish_docker', passwordVariable: 'vish_dockerpass', usernameVariable: 'vish_dockeruser')]) {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve -var "password=$vish_dockerpass"'
                }
                }
	}
	    
       stage('Compose up for selenium test') {
		//building selenium grid for testing
                steps {
                script {
			sh 'docker-compose up -d --scale chrome=3'	
                }
	        }
       }
	    
      stage('Testing on dockerised tomcat'){
		 //testing on dockerisedtomcatcontainer using selenium (3 tests: UUID, SearchTest for string matching and SearchTest2 for failure)
		 steps{
		      sh script:'''
		      cd seleniumtest
		      mvn -Dtest="UUIDTest.java" test -Duuid="$uuid" 
		      '''
		      //mvn -Dtest="SearchTest.java" test
		      //mvn -Dtest="SearchTest2.java" test
		      }
	}  
	    
	stage('Deploy on tomcat in VM'){   
		 //deploying on VM (eg Production Environment)
                  steps{
			  
                       deploy adapters: [tomcat9(credentialsId: 'tomcat', path: '', url: 'http://devopsteamgoa.westindia.cloudapp.azure.com:8081/')], contextPath: 'musicstore', onFailure: false, war: 'musicstore/target/*.war'
		       sh 'curl -sL --connect-timeout 20 --max-time 30 -w "%{http_code}\\\\n" "http://devopsteamgoa.westindia.cloudapp.azure.com:8081/musicstore/index.html" -o /dev/null'
		       script{
                       def response = sh(script: 'curl http://devopsteamgoa.westindia.cloudapp.azure.com:8081/musicstore/version.html', returnStdout: true)
		       if(env.uuid == response)
		       echo 'Latest version deployed'
		       else
		       echo 'Older version deployed'
	               }
	               }
        }
        }//stages closed
	
	//using terraform destroy to remove dockerisedtomcatcontainer and compose down for selenium -always runs
	post{
               always{
               sh 'terraform destroy --auto-approve'
	       sh 'docker-compose down'	       
               }
             }
	
}
