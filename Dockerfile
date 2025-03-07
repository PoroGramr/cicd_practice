# 1. OpenJDK 17 기반으로 빌드 (멀티 스테이지 빌드)
FROM --platform=linux/arm64 openjdk:17-jdk-slim AS build

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. Gradle 캐시 최적화를 위한 의존성만 먼저 복사
COPY gradlew gradlew
COPY gradle gradle
COPY build.gradle settings.gradle ./

# Gradle 권한 설정 및 의존성 다운로드
RUN chmod +x gradlew && \
    ./gradlew dependencies --no-daemon --parallel

# 4. 프로젝트 전체 복사 및 빌드 실행
COPY . .
RUN ./gradlew build --no-daemon --parallel

# 5. 실행 환경을 위한 JRE 17 베이스 이미지
FROM --platform=linux/arm64 eclipse-temurin:17-jre-jammy

# 6. 작업 디렉토리 설정
WORKDIR /app

# 7. 빌드된 JAR 파일 복사
COPY --from=build /app/build/libs/*.jar app.jar

# 8. Java 옵션 설정 및 실행 명령어
ENV JAVA_OPTS="-Xms512m -Xmx1024m"
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
