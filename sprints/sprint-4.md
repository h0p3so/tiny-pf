---
layout: default
title: Sprint 4
---

This section describes the definition of **Sprint 4**, focused on securing the **TechCup Fútbol** backend with Spring Security and JWT authentication, and automating the build, test, and deployment pipeline using GitHub Actions and Azure.

## Part 1 – Security with Spring Boot Security

### Postman – API testing setup

- Each team member must create an account on [Postman Web](https://www.postman.com/).
- One member creates a shared Postman team named `TechCup_<initials of each member's first surname>` (e.g., `TechCup_LCHC`).
- Create a collection called **Users**.
- Build and run the backend project locally.
- Add a request to `GET /api/users` and execute it. Expected response: `200 OK` with the list of users in JSON.
- Take a **screenshot of the Postman result** and add it to `README.md`.

### Adding Spring Security

- Add the Spring Security dependency to `pom.xml`:

  ```xml
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
  </dependency>
  ```

- Rebuild and re-run the GET Users request — Spring Security will now require credentials.
- Use the default user (`user`) and the generated password found in the application startup logs:
  ```
  Using generated security password: <uuid>
  ```
- Configure Basic Auth in Postman with these credentials and verify the endpoint still returns users.
- Take a **screenshot showing the 401 response** (before credentials) and another **after successful authentication**, and add both to `README.md`.
- Override the default credentials in `application.properties`:
  ```properties
  # Security
  spring.security.user.name=techcup_admin
  spring.security.user.password=<your_custom_password>
  ```
- Update Postman with the new credentials and confirm the request still works. Add a **final screenshot** to `README.md`.

### User, Role, and Permission schema

Update the data model to support a complete RBAC (Role-Based Access Control) design. The required ER structure is:

```
Users (*) ——— (1..*) Roles (1..*) ——— (1..*) Permissions
```

- **Users**: `id` (Long, PK), `email` (varchar 50, UK), `password` (char 32)
- **Roles**: `id` (Long, PK), `name` (varchar 20, UK)
- **Permissions**: `id` (Long, PK), `name` (varchar 20, UK)

Implementation tasks:
- Update the `User` and `Role` entity classes with `@ManyToMany` and `@JoinTable`.
- Update the `model` package to reflect the new structure.
- Update the ER diagram in the repository.
- Rebuild and test the `GET /api/users` endpoint — it should now return users with their roles and permissions.

### JWT Authentication

Replace the default Spring Security session-based authentication with **stateless JWT**.

**Goal:** Authenticate a user → generate a JWT → return the token.

Add JWT dependencies to `pom.xml`:

```xml
<!-- JWT -->
<dependency>
  <groupId>io.jsonwebtoken</groupId>
  <artifactId>jjwt-api</artifactId>
  <version>0.13.0</version>
</dependency>
<dependency>
  <groupId>io.jsonwebtoken</groupId>
  <artifactId>jjwt-impl</artifactId>
  <version>0.13.0</version>
  <scope>runtime</scope>
</dependency>
<dependency>
  <groupId>io.jsonwebtoken</groupId>
  <artifactId>jjwt-jackson</artifactId>
  <version>0.13.0</version>
  <scope>runtime</scope>
</dependency>
```

**Repository layer:** Add a `findByEmail(String email)` method to `UserRepository`.

**Service layer:** Add a `loadUserByEmail(String email)` method to `UserService`. This method must:
- Retrieve the user from the repository by email.
- Build and return a `UserDetails` object using their email, hashed password, and a flat list of permissions mapped to `SimpleGrantedAuthority`.

As code comments on this method, answer:
- What is the purpose of `loadUserByEmail`?
- What is `UserDetails` and why is it used?
- What is `SimpleGrantedAuthority` and why is it used?

**Security configuration:** Create a `SecurityConfig` class in a new `security` package with:
- `@Configuration` and `@EnableWebSecurity` annotations.
- A `@Bean` for `AuthenticationManager` using `AuthenticationConfiguration`.
- A `@Bean` for `PasswordEncoder` returning a `BCryptPasswordEncoder`.

As code comments, answer:
- What does `@EnableWebSecurity` do?
- What is `AuthenticationManager` and what is it used for?
- What is `PasswordEncoder` and why is `BCryptPasswordEncoder` preferred?

**JWT service:** Create a `JwtService` class in the `service` package responsible for generating and validating JWT tokens.

### Authorization by roles

- Configure endpoint-level access control so that certain endpoints require specific roles or permissions (e.g., only `ADMIN` can assign roles to users, only `ORGANIZER` can create tournaments).

### Security protections

Apply the following protections to the application:

- **CSRF**: Configure Cross-Site Request Forgery protection (or disable it explicitly for stateless APIs with proper justification).
- **XSS**: Apply response headers or filters to prevent Cross-Site Scripting attacks.
- **Clickjacking**: Add `X-Frame-Options` header configuration to prevent clickjacking.

### Integration test

Write at least one integration test that validates the security layer — for example, verifying that an unauthenticated request to a protected endpoint returns `401 Unauthorized`, and an authenticated request with a valid JWT returns `200 OK`.

## Part 2 – CI/CD with GitHub Actions and Azure

### Continuous Integration pipeline

Create a GitHub Actions workflow file at `.github/workflows/ci-cd.yml`. The workflow must:

- **Trigger**: on `pull_request` to `develop`.
- **Define 3 sequential jobs**:

  ```
  build → test → deploy
  ```

  **`build` job:**
  - Checkout the repository.
  - Set up Java 17.
  - Run `mvn compile` (compile phase only).
  - This job is a prerequisite for `test`.

  **`test` job:**
  - Depends on (`needs: build`).
  - Run `mvn verify` to execute all tests and generate coverage reports.
  - Answer in `README.md`: Can the `test` job skip recompilation if `build` already ran? How?
  - This job is a prerequisite for `deploy`.

  **`deploy` job:**
  - Depends on (`needs: test`).
  - For now, simply print to console:
    ```bash
    echo "En construcción ..."
    ```

### Continuous Deployment to Azure

- **Create an Azure App Service** using a free-tier plan (F1 — $0/month).
- **Update the `deploy` job** to use the `azure/webapps-deploy@v2` GitHub Action to deploy the generated `.jar` to the App Service.
- **Verify the deployed endpoint** in the browser.

Troubleshooting checklist:
- If the app fails to start, check the App Service **Log Stream** for errors.
- The default port for Azure App Service is `80`. Update `application.properties`:
  ```properties
  server.port=80
  ```
- If the app starts but cannot connect to the database, create a **free PostgreSQL database** in Azure and configure the connection via **environment variables** in both App Service settings and `application.properties`:
  ```properties
  spring.datasource.url=${DATABASE_URL}
  spring.datasource.username=${DATABASE_USER}
  spring.datasource.password=${DATABASE_PASSWORD}
  ```

Once the database is configured, the full application should be reachable at the Azure App Service URL.

## Git workflow

| Branch | Purpose |
|---|---|
| `feature/postman` | Postman screenshots and setup |
| `feature/spring-boot-security-dep` | Spring Security dependency and Basic Auth |
| `feature/user-role-design` | Updated ER model with Roles and Permissions |
| `feature/jwt` | JWT authentication implementation |
| `feature/ci-cd` | GitHub Actions workflow and Azure deployment |

All PRs must be reviewed and approved by a team member different from the author before merging to `develop`.

<div class="callout note">
  <div class="callout-title">Note</div>
  The <code>JwtService</code> implementation details (token generation, secret key management, expiration) are left to each team to define, but must follow best practices: use a strong secret, set an appropriate expiration time, and never expose the secret in the repository (use environment variables or <code>application.properties</code> excluded from version control).
</div>

<div class="callout warning">
  <div class="callout-title">Important</div>
  Do <strong>not</strong> create a new repository for this sprint. All work is done on the existing TechCup backend repository.
</div>
