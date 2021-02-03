pipeline {
    agent any
	environment {
        verCode = UUID.randomUUID().toString()
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
			  //get repo
              git 'https://github.com/vishvaja0630/AutomationAssignment.git'
			  
			  //Creating version.html and writing randomUUID to it
		      sh script:'''
		    	touch musicstore/src/main/webapp/version.html
		      '''
		     println verCode
		     writeFile file: "musicstore/src/main/webapp/version.html", text: verCode
            }
        }
	stage('Build maven project'){
		    steps{
			  sh script:'''
			  cd musicstore
			  mvn -Dmaven.test.failure.ignore=true clean package
		      '''
			}
	}
	stage('Docker build and publish tomcat image'){
		steps{
		    script{
			 dockerImage = docker.build("shivani221/dockerisedtomcat")
			 docker.withRegistry( '', registryCredential ) {
                         dockerImage.push("$BUILD_NUMBER")
                         dockerImage.push('latest')
			 }
			}
		}
	}    
	    
	stage('Running the tomcat container') {
		steps{
	         sh 'docker run -d --name dockerisedtomcat -p 9090:8080 shivani221/dockerisedtomcat:latest'
	        }
	 }
	stage('compose up for selenium test') {
            steps {
                script {
			sh 'docker-compose up -d --scale chrome=3'
			
                }
	    }
        }
	stage('Run the tests and remove tomcat docker image once tests are run '){
		    steps{
			  sh script:'''
			  cd seleniumtest
			  mvn -Dtest="SearchTest2.java" test
		          '''
			}
	}    
	  stage('Deploy on tomcat in VM'){   
            steps{
            deploy adapters: [tomcat9(credentialsId: 'tomcat', path: '', url: 'http://devopsteamgoa.westindia.cloudapp.azure.com:8081/')], contextPath: 'musicstore', onFailure: false, war: 'musicstore/target/*.war'
            sh 'curl -I \'http://devopsteamgoa.westindia.cloudapp.azure.com:8081/musicstore/index.html\' | grep HTTP'
		script{
                def response = sh(script: 'curl http://devopsteamgoa.westindia.cloudapp.azure.com:8081/musicstore/version.html', returnStdout: true)
		 if(env.verCode == response)
		      echo 'Latest version deployed'
		 else
		      echo 'Older version deployed'
	         }
	    }
        }
    }
	
		post{
                    always{
                         sh "docker rm -f dockerisedtomcat"
                         }
                     }
	    
}
