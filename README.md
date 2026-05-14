# Food Delivery Platform

Sistema de delivery desenvolvido com **arquitetura de microsserviços orientada a eventos** (Event-Driven Microservices), com foco em escalabilidade, desacoplamento, resiliência e boas práticas de backend em **Java**.

## Visão da arquitetura

```
Frontend
   ↓
API Gateway
   ↓
Auth Service · User Service · Restaurant Service · Order Service · Payment Service · Notification Service
   ↓
Apache Kafka (Event Bus)
```

- **Comunicação síncrona:** REST entre cliente/gateway e serviços quando a resposta imediata é necessária.
- **Comunicação assíncrona:** eventos no Kafka para desacoplar domínios (pedidos, pagamentos, notificações).

## Objetivo do projeto

Simular um ambiente corporativo próximo ao real, exercitando:

- Microsserviços e limites de domínio
- API Gateway
- Autenticação JWT e autorização por roles
- Sistema distribuído e consistência eventual
- Docker e orquestração local com Compose
- Observabilidade (correlation ID, logs, health)
- Processamento orientado a eventos (producers/consumers, retry, DLQ)

## Stack

| Camada | Tecnologias |
|--------|-------------|
| Backend | Java 21, Spring Boot 3, Spring Security, Spring Cloud Gateway, Spring Data JPA |
| Mensageria | Apache Kafka |
| Banco | PostgreSQL |
| Infra | Docker, Docker Compose |
| API | Swagger / OpenAPI |
| Testes | JUnit, Mockito |
| Logs | SLF4J, Logback |

## Microsserviços

| Serviço | Responsabilidade | Porta |
|---------|------------------|-------|
| `gateway-service` | API Gateway | 8080 |
| `auth-service` | Autenticação / JWT | 8081 |
| `user-service` | Usuários | 8082 |
| `restaurant-service` | Restaurantes e cardápio | 8083 |
| `order-service` | Pedidos | 8084 |
| `payment-service` | Pagamentos | 8085 |
| `notification-service` | Notificações | 8086 |

## Funcionalidades (por domínio)

### Autenticação (`auth-service`)

- Registro de usuário
- Login com JWT
- Refresh token
- Roles e permissões

### Usuários (`user-service`)

- Perfil
- Endereço
- Atualização de dados

### Restaurantes (`restaurant-service`)

- Cadastro de restaurantes
- Cardápio: produtos e categorias

### Pedidos (`order-service`)

- Criar pedido
- Atualizar status
- Histórico de pedidos

### Pagamentos (`payment-service`)

- Aprovação / rejeição
- Integração assíncrona com o restante do sistema

### Notificações (`notification-service`)

- E-mail e outros canais conforme implementação
- Eventos / webhooks

## Eventos principais (Kafka)

### `order-created`

```json
{
  "orderId": 1,
  "userId": 15,
  "total": 120.50
}
```

### `payment-approved`

```json
{
  "paymentId": 99,
  "orderId": 1,
  "status": "APPROVED"
}
```

### `notification-send`

```json
{
  "userId": 15,
  "message": "Pedido aprovado"
}
```

## Estrutura do repositório

```
food-delivery-platform/
├── gateway-service/
├── auth-service/
├── user-service/
├── restaurant-service/
├── order-service/
├── payment-service/
├── notification-service/
├── docker-compose.yml
└── README.md
```

### Pacotes sugeridos (por serviço)

`src/main/java/com/fooddelivery`

```
controller · service · repository · entity · dto · mapper · config · security · exception · producer · consumer · event
```

## Segurança

- Autenticação baseada em **JWT** (stateless).
- **Roles:** `ROLE_USER`, `ROLE_ADMIN`, `ROLE_RESTAURANT`.

## Observabilidade

- Correlation ID (rastreio entre gateway e serviços)
- Request logging
- Health checks
- Logs estruturados
- Retry em consumidores Kafka
- Dead Letter Queue (DLQ) para mensagens problemáticas

## Pré-requisitos

- Java 21+
- Maven 3.9+
- Docker e Docker Compose

## Como subir o ambiente

Na raiz do projeto:

```bash
docker-compose up -d
```

Serviços típicos no Compose: **PostgreSQL**, **Zookeeper**, **Kafka** e os microsserviços (ajuste nomes/portas conforme seu `docker-compose.yml`).

## Documentação da API (Swagger)

Cada microsserviço expõe sua própria documentação, por exemplo:

- Auth: `http://localhost:8081/swagger-ui.html`

Substitua a porta conforme a tabela de serviços acima.

## Testes e cobertura

```bash
mvn test
```

**Meta de cobertura:** 70%+ (ajuste no `pom.xml` / Sonar conforme sua política).

## Roadmap sugerido

| Sprint | Entrega |
|--------|---------|
| 1 | Gateway + Auth Service |
| 2 | User Service + integração JWT |
| 3 | Restaurant Service |
| 4 | Order Service |
| 5 | Integração Kafka (producers/consumers) |
| 6 | Payment + Notification |
| 7 | Observabilidade (retry, DLQ, logs, correlation ID) |

## Conceitos aplicados

- Event-Driven Architecture  
- Sistemas distribuídos  
- API Gateway  
- Autenticação stateless (JWT)  
- Comunicação assíncrona  
- REST APIs  
- Retry e DLQ  
- Correlation ID e resiliência  

## Objetivo profissional

Projeto voltado a **aprendizado de arquitetura moderna**, **backend enterprise**, **microsserviços**, **sistemas distribuídos** e preparação para posições **Java Backend Pleno/Sênior**.

---

## Licença

Defina a licença do repositório (por exemplo MIT ou Apache 2.0) e atualize esta seção.
