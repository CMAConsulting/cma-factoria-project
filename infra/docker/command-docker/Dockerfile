# Multi-stage build for Quarkus native application
# Best practices: https://quarkus.io/guides/building-native-image

# Stage 1: Build native executable using Quarkus Mandrel builder
FROM quay.io/quarkus/ubi9-quarkus-mandrel-builder-image:jdk-21 AS build

WORKDIR /build

# Layer 1: Maven wrapper + pom.xml — cached unless pom.xml changes
COPY --chown=quarkus:quarkus --chmod=0755 apps/backend/command-api-ms/mvnw /build/mvnw
COPY --chown=quarkus:quarkus apps/backend/command-api-ms/.mvn /build/.mvn
COPY --chown=quarkus:quarkus apps/backend/command-api-ms/pom.xml /build/pom.xml

# Download dependencies (cached layer)
RUN /build/mvnw -B dependency:go-offline -q

# Layer 2: OpenAPI contracts + source code
COPY --chown=quarkus:quarkus contracts/openapi /build/contracts/openapi
COPY --chown=quarkus:quarkus apps/backend/command-api-ms/src /build/src

# Build native executable — already inside Mandrel, no container-build flag needed
# openapi.spec.path overrides the relative path from pom.xml that doesn't resolve inside the container
RUN /build/mvnw package -Pnative -DskipTests -q \
    -Dopenapi.spec.path=/build/contracts/openapi/commands.yaml

# Stage 2: Minimal runtime image
FROM quay.io/quarkus/ubi9-quarkus-micro-image:2.0

WORKDIR /work/

RUN chown 1001 /work \
    && chmod "g+rwX" /work \
    && chown 1001:root /work

# Native runner is at target/*-runner (not target/quarkus-app/bin/ which is JVM only)
COPY --from=build --chown=1001:root --chmod=0755 /build/target/*-runner /work/application

EXPOSE 8080
USER 1001

ENTRYPOINT ["./application", "-Dquarkus.http.host=0.0.0.0"]
