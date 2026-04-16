# Multi-stage build for Quarkus native application
# Best practices: https://quarkus.io/guides/building-native-image
# Optimized for Docker BuildKit caching

# Stage 1: Build native executable using Quarkus Mandrel builder
FROM quay.io/quarkus/ubi9-quarkus-mandrel-builder-image:jdk-21 AS build

WORKDIR /build

# Layer 1: Copy project files
COPY --chown=quarkus:quarkus --chmod=0755 apps/backend/command-api-ms/mvnw /build/mvnw
COPY --chown=quarkus:quarkus apps/backend/command-api-ms/.mvn /build/.mvn
COPY --chown=quarkus:quarkus apps/backend/command-api-ms/pom.xml /build/pom.xml

# Download dependencies
RUN chmod +x /build/mvnw && /build/mvnw -B dependency:go-offline -q

# Copy source code
COPY --chown=quarkus:quarkus contracts/openapi /build/contracts/openapi
COPY --chown=quarkus:quarkus apps/backend/command-api-ms/src /build/src

# Build native executable with -Pnative to activate profile
RUN /build/mvnw package -DskipTests -Pnative \
    -Dquarkus.native.container-build=true \
    -Dquarkus.native.must-match=true \
    -Dopenapi.skip=true \
    -q

# Stage 2: Minimal runtime image (UBI micro)
FROM quay.io/quarkus/ubi9-quarkus-micro-image:2.0

WORKDIR /work/

# Copy native executable from quarkus-app/bin/ (Quarkus 3.7+)
COPY --from=build --chown=quarkus:quarkus --chmod=0755 /build/target/quarkus-app/bin/* /work/application

EXPOSE 8080
USER 1001

ENTRYPOINT ["./application", "-Dquarkus.http.host=0.0.0.0"]