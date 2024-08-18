# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jdk

# Copy the application JAR file into the container
COPY target/cartpuller2.jar .

# Expose the port your Spring Boot app runs on
EXPOSE 8080

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "cartpuller2.jar"]
