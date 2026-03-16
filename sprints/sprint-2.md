---
layout: default
title: Sprint 2 – SpringBoot API REST
---

This section describes the definition of **Sprint 2**, focused on structuring the backend of the **TechCup Fútbol** platform using Spring Boot and exposing the first REST API endpoints for the core features: Authentication, Users, and Tournaments.

## Back-end structure

- **Initialize the Spring Boot backend project**: Using [Spring Initializr](https://start.spring.io/), create a Maven project with Spring Boot, Java 17, and the proper metadata for the TechCup backend. The resulting structure should include packages for `controller`, `service`, `repository`, `entity`, `model`, `dto`, `exception`, and `config`.
- **Add core dependencies**: Include in `pom.xml` the required dependencies for testing and quality: `JUnit`, `JaCoCo`, and `SonarQube`. These will be the foundation for applying TDD and measuring code coverage throughout the project.
- **Answer architectural questions**: As part of the documentation (`README.md`), answer the following questions about the Spring Boot package structure:
  - What is the purpose of the `Controller` package?
  - What is the purpose of the `Service` package?
  - What is the purpose of the `Repository` package?
  - What is the purpose of the `Entity` package?
  - What is the purpose of the `DTO` package?
  - What is the purpose of the `Exception` package?

  Include APA-formatted bibliography to support your answers.

## TDD and documentation

- **Integrate TDD artifacts**: Update the backend project with the TDD artifacts and requirements defined in previous labs. Only include tests that cover the three core requirements: Authentication, Users (CRUD), and Tournaments (CRUD).
- **Update README.md**: Document everything relevant from the prior analysis and design phase, including class diagrams, descriptions of entities, and any design decisions made.

## API construction – First cycle

Build the first version of the REST API for the TechCup platform. The following rules apply:

### Users
- Users are created with the **player** role by default.
- Only the system administrator can assign a different role to a user.
- Users **cannot be deleted** — they can only be deactivated (no `DELETE` endpoint for users).

### Tournaments
- Tournaments are created in **Draft** status by default.
- Tournaments **cannot be modified** if they are in **Finished** status.
- A tournament can only be **deleted** if it is in **Draft** status.

### Authentication
- The authentication method is `POST`.
- Credentials are validated using email and password.

**Implementation tasks:**
- Define REST controllers using `@RestController` and `@RequestMapping` for `UserController`, `TournamentController`, and `AuthController`.
- Define all necessary operations per controller, using proper HTTP method annotations (`@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`) and return appropriate HTTP status codes (e.g., `ResponseEntity.status(HttpStatus.UNAUTHORIZED)`).
- Define service classes annotated with `@Service`. Since persistence is not yet implemented, simulate data using in-memory structures:
  - **GET** methods: return dummy model objects.
  - **POST** methods: return a new model object simulating creation.
  - **PUT** methods: simulate an update using existing dummy data.
  - **DELETE** methods: simulate deletion using existing dummy data.

## API documentation – Swagger

- **Add springdoc-openapi dependency** to `pom.xml`:
  ```xml
  <dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.6.0</version>
  </dependency>
  ```
- **Annotate controllers** with `@Tag`, `@Operation`, and related Swagger annotations to describe each endpoint.
- **Create a `SwaggerConfig` class** in the `config` package to define the API title, version, and description using `OpenAPI` and `Info`.
- **Verify the Swagger UI** by running the application and navigating to `http://localhost:8080/swagger-ui.html`.
- Add a **screenshot of the generated Swagger UI** to `README.md`.

## Logging

- **Integrate SLF4J** into all service classes to register actions and errors. Use `LoggerFactory.getLogger(ClassName.class)` and log with `log.debug(...)` and `log.info(...)`.
- **Configure the log file name** in `application.properties`:
  ```properties
  logging.file.name=logs/tech-cup.log
  ```

## Git workflow

Each task in this sprint must follow the branching and PR strategy defined for the project:

| Branch | Purpose |
|---|---|
| `feature/scaffolding` | Initial project structure |
| `feature/resources` | TDD artifacts and README update |
| `feature/springboot-questions` | Architectural questions in README |
| `feature/first-cycle` | Entity/service/controller classes for the first cycle |
| `feature/api-rest-first-cycle` | REST API implementation |
| `feature/swagger-first-cycle` | Swagger documentation |
| `feature/logs-first-cycle` | SLF4J logging integration |

Every PR must be reviewed and approved by a team member different from the one who created it before merging to `develop`.

<div class="callout note">
  <div class="callout-title">Note</div>
  Since persistence is not yet implemented in this sprint, all service methods should use in-memory data (lists, dummy objects). The real database integration is planned for the following sprint.
</div>
