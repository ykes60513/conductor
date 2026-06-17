#
# conductor:server - Build Conductor Server
#
# ===========================================================================================================
# 0. Builder stage 1
# ===========================================================================================================
FROM azul/zulu-openjdk-debian:17 AS builder

ARG INDEXING_BACKEND=elasticsearch

LABEL maintainer="Orkes OSS <oss@orkes.io>"

# Copy the project directly onto the image
COPY . /conductor
WORKDIR /conductor

# Build the server on run
RUN ./gradlew build -x test -x spotlessCheck -PindexingBackend=${INDEXING_BACKEND}
WORKDIR /server/build/libs
RUN ls -ltr

# ===========================================================================================================
# 2. Bin stage
# ===========================================================================================================
FROM alpine:3.20

LABEL maintainer="Orkes OSS <oss@orkes.io>"

RUN apk add openjdk17
RUN apk add nginx
RUN apk add curl

# Make app folders
RUN mkdir -p /app/config /app/logs /app/libs /otel

# Copy the compiled output to new image
COPY /otel/opentelemetry-javaagent.jar /otel/opentelemetry-javaagent.jar
COPY docker/server/bin /app
COPY docker/server/config /app/config
COPY --from=builder /conductor/server/build/libs/*boot*.jar /app/libs/conductor-server.jar

# Copy the files for the server into the app folders
RUN chmod +x /app/startup.sh

HEALTHCHECK --interval=60s --timeout=30s --retries=10 CMD curl -I -XGET http://localhost:8080/health || exit 1

CMD [ "/app/startup.sh" ]
ENTRYPOINT [ "/bin/sh"]