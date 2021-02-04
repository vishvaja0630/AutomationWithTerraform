pipeline {
    agent any
	environment {
        UUID uuid = UUID.randomUUID()
        registryCredential ='docker'
	containerName = "shraddhal/seleniumtest2"
        container_version = "1.0.0.${BUILD_ID}"
        dockerTag = "${containerName}:${container_version}"
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
	    
	//Creating and running dockerisedtomcat container using terraform   
	stage('Create and run containers using terraform'){
                 steps{
		 withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'dockerpass', usernameVariable: 'dockeruser')]) {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve -var "password=$dockerpass"'
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
		 //testing on dockerised tomcat using selenium
		 steps{
		      sh script:'''
		      cd seleniumtest
		      mvn -Dtest="UUIDTest.java" test -Duuid="$uuid" 
		      '''
		      //mvn -Dtest="SearchTest.java" test
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
        }
	
	//using terraform destroy to remove container dockerisedtomcat
	post{
               always{
               sh 'terraform destroy --auto-approve'
               }
             }
	
}
