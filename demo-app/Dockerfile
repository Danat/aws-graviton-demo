FROM amazoncorretto:17-alpine AS builder
WORKDIR /app

# Install Gradle
RUN apk add --no-cache wget unzip
RUN wget https://services.gradle.org/distributions/gradle-8.5-bin.zip -P /tmp
RUN unzip -d /opt/gradle /tmp/gradle-8.5-bin.zip
ENV GRADLE_HOME=/opt/gradle/gradle-8.5
ENV PATH=${GRADLE_HOME}/bin:${PATH}

COPY build.gradle.kts settings.gradle.kts ./
COPY src ./src
RUN gradle bootJar --no-daemon

FROM amazoncorretto:17-alpine
RUN apk add --no-cache curl
WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]