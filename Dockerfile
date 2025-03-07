# 1. OpenJDK 17 기반으로 빌드
FROM eclipse-temurin:17-jdk AS build

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. Gradle 캐시 최적화를 위한 의존성만 먼저 복사
COPY gradlew gradlew
COPY gradle gradle
COPY build.gradle settings.gradle ./
RUN chmod +x gradlew && ./gradlew dependencies --no-daemon

# 4. 프로젝트 전체 복사 및 빌드 실행
COPY . .
RUN ./gradlew build --no-daemon

# 5. 실행 환경을 위한 JDK 17 베이스 이미지
FROM eclipse-temurin:17-jre

# 6. 작업 디렉토리 설정
WORKDIR /app

# 7. 빌드된 JAR 파일 복사
COPY --from=build /app/build/libs/*.jar app.jar

# 8. 실행 명령어 설정
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
