# ============================================================================
# Dockerfile - Mottu Yard Application
# Imagem oficial: Eclipse Temurin (OpenJDK da Eclipse Foundation)
# Execução: Usuário não-root (spring:spring) para segurança
# ============================================================================

FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="Mottu Yard Team"
LABEL description="Sistema de Gestão de Pátios de Motos"
LABEL version="1.0"

WORKDIR /app

# Criar usuário não-root para segurança (container NÃO roda como root)
RUN addgroup -S spring && adduser -S spring -G spring

# Copiar JAR já compilado (build feito localmente pelo script)
COPY mottu-yard.jar app.jar

# Mudar ownership para usuário spring
RUN chown -R spring:spring /app

# Trocar para usuário não-root
USER spring:spring

# Expor porta da aplicação
EXPOSE 8080

# Configurar JVM para container
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Comando de inicialização
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
