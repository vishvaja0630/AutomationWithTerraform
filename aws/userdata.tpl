  
#!/bin/bash -e
sudo amazon-linux-extras install tomcat8.5 
sudo systemctl enable tomcat
sudo systemctl start tomcat
sudo cp /tmp/MusicStore.war /usr/share/tomcat/webapps/MusicStore.war
