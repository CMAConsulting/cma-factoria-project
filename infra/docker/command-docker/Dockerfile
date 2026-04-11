FROM docker.io/maven:3.9-eclipse-temurin-21 AS builder

RUN apt-get update && apt-get install -y \
    gcc \
    libc6-dev \
    libz-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build/apps/backend/command-api-ms

COPY apps/backend/command-api-ms/pom.xml pom.xml
COPY contracts/openapi /build/contracts/openapi

COPY apps/backend/command-api-ms/src src

RUN mvn dependency:go-offline -B -q

RUN mvn package -DskipTests -B -Dnative \
    -Dopenapi.spec.path=/build/contracts/openapi/commands.yaml \
    -Dquarkus.native.container-build=true \
    -Dquarkus.native.must-match=true

FROM docker.io/amazonlinux:2023

COPY --from=builder /build/apps/backend/command-api-ms/target/*-runner .

RUN chmod +x /*-runner

EXPOSE 8080

ENTRYPOINT ["./-runner"]