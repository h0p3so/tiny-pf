---
layout: default
title: Sprint 3 – Data Persistence & Image Microservice
---

This section describes the definition of **Sprint 3**, focused on replacing the in-memory data layer with real persistence using **JPA + PostgreSQL** for the main project, and building an independent **image microservice** backed by **MongoDB**.

## Database design

- **Create the Entity-Relationship (ER) diagram** for the TechCup project. This diagram must reflect the entities required for: Authentication, Users (CRUD), and Tournaments (CRUD), along with their relationships. The diagram should be placed at `docs/datos/Datos.md` in the repository.
- **Select at least 3 domain entities** to persist in the relational database. For TechCup, these must cover:
  - Authentication (e.g., `User` with credentials)
  - Users CRUD (e.g., `User`, roles, profile information)
  - Tournament CRUD (e.g., `Tournament` with its status lifecycle: Draft → Active → In Progress → Finished)

  Document your entity selection and the justification in `README.md`.

## Part A – Relational persistence with JPA

### Dependencies

Add the following dependencies to `pom.xml` of the main project:

```xml
<!-- JPA -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- PostgreSQL -->
<dependency>
  <groupId>org.postgresql</groupId>
  <artifactId>postgresql</artifactId>
  <scope>runtime</scope>
</dependency>

<!-- H2 for tests -->
<dependency>
  <groupId>com.h2database</groupId>
  <artifactId>h2</artifactId>
  <scope>test</scope>
</dependency>

<!-- Validation -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

### JPA entities

- **Annotate each domain class** as a JPA entity:
  - Add `@Entity` to each class.
  - Define `@Table(name = "...")` when the table name differs from the class name.
  - Add an `id` field annotated with `@Id` and `@GeneratedValue(strategy = GenerationType.IDENTITY)`.
  - Configure columns with `@Column` (nullable, unique, length as required).
  - Add a no-argument constructor, getters, and setters.
  - Apply `@NotBlank` or other Bean Validation constraints where appropriate.

### Entity relationships

- Map **at least one real relationship** between entities. For TechCup, relevant relationships include:
  - A `User` participates in a `Tournament` through a `Team`.
  - A `Team` belongs to a `Tournament`.
  - A `User` has one or more `Roles`.

  Use the appropriate JPA annotations: `@ManyToOne`, `@OneToMany`, `@OneToOne`, or `@ManyToMany`. Define foreign keys with `@JoinColumn` where applicable.

### JPA repositories

- Create **one repository interface per entity** in the `repository` package:
  - Extend `JpaRepository<Entity, Long>`.
  - Add at least one derived query method per repository (e.g., `findByEmail`, `findByStatus`, `findByNombreContainingIgnoreCase`).

### PostgreSQL setup

Spin up a local PostgreSQL instance using Docker:

```bash
docker run --name postgres-techcup \
  -e POSTGRES_DB=techcupdb \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  -d postgres
```

Configure `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/techcupdb
spring.datasource.username=postgres
spring.datasource.password=postgres
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
```

When the application starts it should connect to PostgreSQL without errors and auto-create or update the tables.

### Service layer update

- **Update all services** created in the previous sprint to use real persistence instead of in-memory lists.
- Inject repositories via constructor injection.
- Inject any required mappers via constructor injection.
- Map between model objects and JPA entities using mapper classes (model → entity and entity → model).

### Controller update

- **Update all controllers** to use the updated services.
- Inject services via constructor injection (no direct repository access from controllers).

### H2 configuration for tests

Create `src/test/resources/application-test.properties`:

```properties
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
```

Ensure all tests use the `test` profile with `@ActiveProfiles("test")`.

### Repository tests

Write at minimum the following tests for each repository (using `@DataJpaTest`):

- A **save** test: verify that an entity is persisted and its auto-generated ID is not null.
- A **query** test: verify that a derived query method returns the expected results.
- A **relationship** test: verify that a related entity is correctly loaded.
- An **update or delete** test: verify that modification or removal works correctly.

Run all tests with:
```bash
mvn test
```
Tests must pass using H2 **without requiring a running PostgreSQL instance**.

Add evidence of successful test execution to `README.md`.

## Part B – Image microservice with MongoDB

Create a **second, independent repository** for a Spring Boot microservice dedicated to managing all images in the TechCup project (tournament images, player photos, team shields, etc.).

### Project setup

Suggested name: `image-service`

Required dependencies:

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-mongodb</artifactId>
</dependency>
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-test</artifactId>
  <scope>test</scope>
</dependency>
```

### Project structure

```
src/main/java/edu/eci/dosw/imageservice/
├── controller/
├── service/
├── repository/
├── model/
│   └── document/
└── config/
```

### MongoDB setup

Spin up a local MongoDB instance using Docker:

```bash
docker run --name mongo-techcup -p 27017:27017 -d mongo
```

Configure `src/main/resources/application.properties`:

```properties
spring.data.mongodb.uri=mongodb://localhost:27017/techcupimages
server.port=8081
```

### MongoDB document

Create an `ImagenDocument` class in `model/document` annotated with `@Document(collection = "imagenes")`. Fields should include: `id` (String, `@Id`), `nombre`, `tipoContenido`, `tamano`, `datos` (byte[]), `fechaCarga` (LocalDateTime), and `referenciaExterna` (used to link an image to a tournament, team, or player).

### Repository

Create `ImagenRepository` extending `MongoRepository<ImagenDocument, String>`. Add a derived query: `findByReferenciaExterna(String referenciaExterna)`.

### Service

Implement `ImagenService` with the following methods:

- `guardar(MultipartFile archivo, String referenciaExterna)` — stores a new image.
- `buscarPorId(String id)` — retrieves an image by ID.
- `listar()` — returns all stored images.
- `listarPorReferencia(String referenciaExterna)` — returns images linked to a given entity.
- `eliminar(String id)` — deletes an image by ID.

### REST controller

Implement `ImagenController` at `/imagenes` with the following endpoints:

| Method | Path | Description |
|---|---|---|
| `POST` | `/imagenes` | Upload an image (`multipart/form-data`) |
| `GET` | `/imagenes` | List all images |
| `GET` | `/imagenes/{id}` | Get image bytes by ID |
| `GET` | `/imagenes/referencia/{ref}` | List images by external reference |
| `DELETE` | `/imagenes/{id}` | Delete an image |

### Validation

Test the microservice using Postman, Insomnia, or Swagger. The minimum required cases are: upload an image, list images, retrieve an image by ID, delete an image, and list images by external reference.

Add evidence of MongoDB storage to `README.md` of the image-service repository.

## Git workflow

| Branch | Purpose |
|---|---|
| `feature/erd-modeling` | ER diagram |
| `feature/entities-selection` | Entity selection and justification |
| `feature/database` | Main database branch |
| `feature/entities` | JPA entity classes |
| `feature/relationships` | Entity relationships |
| `feature/repositories` | JPA repository interfaces |
| `feature/h2-setup` | H2 test configuration |
| `feature/services` | Updated services with persistence |
| `feature/controllers` | Updated controllers |

All branches must be merged to `develop` via PR, reviewed and approved by a different team member.

<div class="callout note">
  <div class="callout-title">Note</div>
  The image microservice lives in a <strong>separate repository</strong> and runs on port <code>8081</code>. It is independent of the main TechCup backend but will be consumed by it in future sprints when team shields and player photos are needed.
</div>

<div class="callout warning">
  <div class="callout-title">Important</div>
  Each team member works on their assigned entities in <strong>independent branches</strong>. When all branches are merged into <code>develop</code>, the complete data model will be assembled.
</div>
