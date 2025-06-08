FROM eclipse-temurin:21-jdk AS builder
WORKDIR /app
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN chmod +x ./mvnw
RUN ./mvnw dependency:go-offline -B
COPY src ./src
RUN ./mvnw package -DskipTests -B

FROM eclipse-temurin:21-jdk AS runner
WORKDIR /app
COPY --from=builder /app/mvnw .
COPY --from=builder /app/.mvn .mvn
COPY --from=builder /app/pom.xml .
COPY --from=builder /app/src ./src
COPY --from=builder /app/target/classes ./target/classes
COPY --from=builder /app/target/test-classes ./target/test-classes
EXPOSE 8080
CMD ["./mvnw", "spring-boot:run"]
