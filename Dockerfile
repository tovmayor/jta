FROM tomcat:jre8-temurin-jammy
ADD hello-1.0.war /usr/local/tomcat/webapps

EXPOSE 8080
CMD ["catalina.sh" "run"]
