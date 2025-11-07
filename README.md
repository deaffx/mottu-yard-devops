# Sprint 4 - FIAP DevOps & Cloud Computing

Sistema de gerenciamento de pátios de motos com CRUD completo, autenticação GitHub OAuth2, e CI/CD automatizado na Azure. 

---

## 👥 Equipe

- **Thiago Moreno Matheus** - RM554507 - 2TDSA
- **Celso Canaveze Teixeira Pinto** - RM556118 - 2TDSA

---

## 📋 1. Descrição da Solução

**Mottu Yard** é uma aplicação web para gerenciamento de pátios de motocicletas com:

- ✅ CRUD completo de Pátios, Motos e Manutenções
- ✅ Autenticação segura via GitHub OAuth2
- ✅ Controle de perfis (OPERADOR/MECÂNICO)
- ✅ Deploy automatizado com CI/CD
- ✅ Banco de dados PostgreSQL em nuvem

### Stack Tecnológica

| Camada | Tecnologia |
|--------|-----------|
| Backend | Java 17, Spring Boot 3.5.4, Spring Security, Spring Data JPA |
| Frontend | Thymeleaf, Bootstrap, Bootstrap Icons |
| Banco de Dados | PostgreSQL 16 (Azure Flexible Server) |
| Build | Gradle 8.5 |
| Container | Docker, Azure Container Registry (ACR) |
| Deploy | Azure Container Instance (ACI) |
| CI/CD | Azure DevOps Pipelines |
| Versionamento | GitHub |

---

## 🗄️ 2. Banco de Dados em Nuvem

**Tecnologia**: Azure Database for PostgreSQL Flexible Server 16  
**Tier**: Burstable (B1ms)  
**Storage**: 32GB com backup automático  
**SSL**: Obrigatório (`sslmode=require`)

### Schema do Banco

4 tabelas gerenciadas pelo Flyway:

```sql
usuarios      -- Autenticação GitHub (github_id, username, avatar, role)
patios        -- Pátios (nome, endereco, capacidade, cidade, estado)
motos         -- Motos (modelo, placa, ano, marca, patio_id)
manutencoes   -- Manutenções (tipo, descricao, status, data, moto_id)
```

Migrations em: `src/main/resources/db/migration/V001__*.sql`

---

## 🚀 3. Pipeline CI/CD

### Configuração Inicial

**Arquivo**: `azure-pipelines.yml` (YAML mode)

### Service Connections Necessárias

1. **Azure Resource Manager** (nome: `Azure-ServiceConnection`):
   - Settings → Service connections → New service connection
   - Tipo: Azure Resource Manager
   - Escopo: Subscription
   - Nome: `Azure-ServiceConnection`

2. **Docker Registry** (nome: `ACR-ServiceConnection`):
   - New service connection → Docker Registry
   - Tipo: Azure Container Registry
   - Nome: `ACR-ServiceConnection`
   - ACR: Selecione seu ACR

### Variáveis da Pipeline

Configure em: **Pipelines → Edit → Variables**

| Nome | Valor | Secret? |
|------|-------|---------|
| `ACR_NAME` | `mottuyardacr[NUMERO]` | ❌ |
| `ACR_LOGIN_SERVER` | `mottuyardacr[NUMERO].azurecr.io` | ❌ |
| `ACR_USERNAME` | (do ACR) | ✅ |
| `ACR_PASSWORD` | (do ACR) | ✅ |
| `RESOURCE_GROUP` | `rg-mottu-yard` | ❌ |
| `ACI_NAME` | `mottu-yard-aci` | ❌ |
| `DB_SERVER` | `mottuyarddb[NUMERO].postgres.database.azure.com` | ❌ |
| `DB_NAME` | `challenge` | ❌ |
| `DB_USER` | `mottuadmin` | ✅ |
| `DB_PASS` | (senha do PostgreSQL) | ✅ |
| `GITHUB_CLIENT_ID` | (GitHub OAuth App) | ✅ |
| `GITHUB_CLIENT_SECRET` | (GitHub OAuth App) | ✅ |

### Estrutura da Pipeline (2 Stages)

#### **Stage 1: Build (CI)**
- ✅ **Trigger**: Push na branch `main` (automático)
- ✅ **Checkout** do código GitHub
- ✅ **Setup** Java 17 (Temurin)
- ✅ **Cache** Gradle dependencies
- ✅ **Build**: `./gradlew clean build`
- ✅ **Testes**: JUnit executado automaticamente
- ✅ **Publicação**: Resultados dos testes + artifact (.jar)

#### **Stage 1.5: BuildAndPushImage (CI)**
- ✅ **Download** do artifact (.jar)
- ✅ **Copy** JAR para nome esperado pelo Dockerfile
- ✅ **Docker Login** no ACR (via ServiceConnection)
- ✅ **Docker Build**: Cria imagem com tags `latest` e `$(Build.BuildId)`
- ✅ **Docker Push**: Envia imagem para ACR

#### **Stage 2: Deploy_ACI (CD)**
- ✅ **Trigger**: Após Stage 2 (automático)
- ✅ **Delete** container antigo
- ✅ **Create** novo container ACI:
  - Imagem do ACR
  - Variáveis de ambiente protegidas (DB, GitHub OAuth)
  - 2 CPUs, 2GB RAM
  - Porta 8080 exposta
  - DNS público

### Requisitos Atendidos

| Requisito | Status |
|-----------|--------|
| I. Conectada ao GitHub | ✅ |
| II. CI dispara ao push na main | ✅ |
| III. CD dispara após CI | ✅ |
| IV. Variáveis protegidas | ✅ |
| V. Artifact publicado | ✅ |
| VI. Testes executados | ✅ |
| VII. Deploy com Docker em ACI | ✅ |

---

## 🛠️ Como Executar Localmente

### Pré-requisitos

- JDK 17
- Docker Desktop
- GitHub OAuth App ([criar aqui](https://github.com/settings/developers))

### 1. Clonar e Configurar

```bash
git clone https://github.com/deaffx/mottu-yard-devops.git
cd mottu-yard-devops
```

Crie `.env`:

```properties
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/challenge
SPRING_DATASOURCE_USERNAME=challenge
SPRING_DATASOURCE_PASSWORD=challenge
SPRING_FLYWAY_ENABLED=true
GITHUB_CLIENT_ID=seu-client-id
GITHUB_CLIENT_SECRET=seu-client-secret
```

### 2. Subir PostgreSQL

```bash
docker-compose up -d
```

### 3. Build e Testes

```bash
./gradlew clean build test
```

Relatório: `build/reports/tests/test/index.html`

### 4. Executar

```bash
./gradlew bootRun
```

Acesse: http://localhost:8080

---

## ☁️ Provisionamento na Azure

### Script Automatizado

```bash
cd infra
chmod +x provision.sh
./provision.sh
```

**Recursos criados**:
- Resource Group: `rg-mottu-yard`
- Container Registry: `mottuyardacr[RANDOM]`
- PostgreSQL Server: `mottuyarddb[RANDOM]`
- Database: `challenge`

**Outputs**:
```
ACR_NAME=mottuyardacr12345
ACR_LOGIN_SERVER=mottuyardacr12345.azurecr.io
ACR_USERNAME=mottuyardacr12345 (secret)
ACR_PASSWORD=*** (secret)
DB_SERVER=mottuyarddb12345.postgres.database.azure.com
DB_NAME=challenge
DB_USER=mottuadmin
DB_PASS=***
```

---

### Conectar ao PostgreSQL (VS Code)

1. Instale extensão: **PostgreSQL by Chris Kolkman**
2. Adicione conexão:
   - **Host**: `mottuyarddb[NUMERO].postgres.database.azure.com`
   - **User**: `mottuadmin`
   - **Password**: (sua senha)
   - **Database**: `challenge`
   - **Port**: 5432
   - **SSL**: Enabled

### Rebuild Local

```bash
./gradlew clean build
docker build -t mottu-yard:local .
docker run -p 8080:8080 \
  -e DB_URL="jdbc:postgresql://..." \
  -e DB_USER="..." \
  -e DB_PASS="..." \
  -e GITHUB_CLIENT_ID="..." \
  -e GITHUB_CLIENT_SECRET="..." \
  mottu-yard:local
```

---

## 🧹 Limpeza de Recursos

```bash
cd infra
./cleanup.sh
```

Ou manualmente:

```bash
az group delete --name rg-mottu-yard --yes --no-wait
```

---

## 📚 Documentação Adicional

- **GitHub OAuth Setup**: https://github.com/settings/developers
- **Azure DevOps Docs**: https://docs.microsoft.com/azure/devops/
- **PostgreSQL VS Code**: Ver `VSCODE_POSTGRES.md`
- **Docker Best Practices**: Ver `Dockerfile`
- **Flyway Migrations**: `src/main/resources/db/migration/`

---

## 📄 Licença

Projeto acadêmico - FIAP 2024 - Sprint 4  
Disciplina: DevOps & Cloud Computing com Java Advanced

---
