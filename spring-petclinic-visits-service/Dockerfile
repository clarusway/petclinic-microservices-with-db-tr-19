FROM openjdk:11-jre
ENV SPRING_PROFILES_ACTIVE docker,mysql
WORKDIR /app
COPY ./target/*.jar app.jar
EXPOSE 8082
CMD ["java", "-jar", "./app.jar"]