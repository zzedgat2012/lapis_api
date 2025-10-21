# Project Requirements - Legal API

## Overview

REST API for managing legal entities using Lapis framework on OpenResty.

## User Stories

### Epic: User Management CRUD

| ID | Title | As a | I want to | So that | Acceptance Criteria |
| --- | --- | --- | --- | --- | --- |
| US-001 | List All Users | API consumer | Retrieve a list of all users | I can display them in my application | GET `/users` returns JSON array of all users; Response includes user id, name, email, created_at; Returns 200 OK status code; Returns empty array if no users exist |
| US-002 | Get User by ID | API consumer | Retrieve a specific user by ID | I can display user details | GET `/users/:id` returns user data for valid ID; Returns 404 Not Found for non-existent ID; Returns 400 Bad Request for invalid ID format; Response includes all user fields |
| US-003 | Create New User | API consumer | Create a new user | I can add users to the system | POST `/users` with name and email creates user; Returns 201 Created on success; Returns 400 Bad Request if name is missing; Returns 400 Bad Request if email is missing; Returns 409 Conflict if email already exists; Auto-generates unique ID; Auto-sets created_at timestamp |
| US-004 | Update Existing User | API consumer | Update user information | I can keep user data current | PUT `/users/:id` updates user fields; Can update name, email, or both; Returns 200 OK with updated user; Returns 404 Not Found for non-existent ID; Returns 409 Conflict if new email already exists; Sets updated_at timestamp |
| US-005 | Delete User | API consumer | Remove a user from the system | I can clean up inactive users | DELETE `/users/:id` removes user; Returns 200 OK with success message; Returns 404 Not Found for non-existent ID; User is permanently removed from database |

### Epic: API Interoperability

| ID | Title | As a | I want to | So that | Acceptance Criteria |
| --- | --- | --- | --- | --- | --- |
| US-006 | Expose OpenAPI Specification | Frontend or integration developer | Access an OpenAPI description of the API | I can integrate the backend with any client or tooling agnostically | OpenAPI 3.x JSON document available at `GET /openapi.json`; Specification covers all user endpoints, parameters, request bodies, and responses; Endpoint responds with `200 OK` and `application/json` content type; Specification version increases when routes or schemas change; Documentation includes instructions to regenerate or update the OpenAPI file |
| US-007 | Provide Swagger UI | Developer or tester | Explore and try API endpoints interactively via the browser | I can prototype and validate integrations quickly without custom tooling | Swagger UI available at `/docs` (or configured path); UI loads the published OpenAPI spec automatically; Supports making authenticated/unauthenticated requests that mirror API behavior; Deployment instructions documented for local and production environments |

### Epic: Developer Tooling Automation

| ID | Title | As a | I want to | So that | Acceptance Criteria |
| --- | --- | --- | --- | --- | --- |
| US-008 | Generate Models via Make | Backend developer | Scaffold domain artifacts with a single Make command | I can work faster with consistent boilerplate similar to Laravel/Rails generators | Running `make model -n <Name>` creates `models/<name>.lua` with a stub module and a timestamped migration file seeded with the model name; Generator aborts with a helpful error when the name is missing or already present; Running `make model -s crud -n <Name>` additionally creates presenter, view, and test skeletons aligned with CRUD routes plus the same migration; CLI help (`make help` or README) documents both usage patterns and flags |

### Epic: Database Engine Support

| ID | Title | As a | I want to | So that | Acceptance Criteria |
| --- | --- | --- | --- | --- | --- |
| US-009 | Support PostgreSQL | DevOps engineer | Run the API against PostgreSQL with minimal configuration | I can prepare the service for production-ready infrastructure | Docker Compose includes a PostgreSQL service that the Lapis container can depend on; `config.lua` exposes a PostgreSQL block driven by environment variables; Application boots and passes migrations/tests against PostgreSQL; Documentation updated with setup, migration, and troubleshooting steps |
| US-010 | Support MySQL | DevOps engineer | Run the API against MySQL with minimal configuration | I can integrate with environments where MySQL is the standard | Docker Compose optionally includes a MySQL service wired to the app; `config.lua` exposes a MySQL block driven by environment variables; Application boots and passes migrations/tests against MySQL; Documentation describes driver installation, configuration toggles, and known limitations |

## Technical Requirements

### Database

| Environment | Requirements |
| --- | --- |
| Development | Default to MySQL for day-to-day development without manual setup; Provide documented toggles to switch to SQLite or PostgreSQL when needed; Ensure migrations run against any selected backend |
| Production | Prefer PostgreSQL with connection pooling; Offer MySQL as an alternative when mandated; Provide guidance on configuring credentials, SSL, and migration execution |

### Validation Rules

| Field | Rule |
| --- | --- |
| `name` | Required, non-empty string |
| `email` | Required, non-empty string, must be unique |
| `id` | Auto-generated, positive integer |
| `created_at` | Auto-generated, Unix timestamp |
| `updated_at` | Auto-set on update, Unix timestamp |

### API Response Format

**Success Response:**

```json
{
  "success": true,
  "user": { ... } // or "users": [...]
}
```

**Error Response:**

```json
{
  "success": false,
  "error": "Error message"
}
```

### HTTP Status Codes

| Status | Meaning |
| --- | --- |
| `200 OK` | Successful GET, PUT, DELETE |
| `201 Created` | Successful POST |
| `400 Bad Request` | Invalid input |
| `404 Not Found` | Resource not found |
| `409 Conflict` | Duplicate resource |

## Non-Functional Requirements

| Category | Requirements |
| --- | --- |
| Performance | Response time < 100ms for simple queries; Support at least 100 concurrent requests |
| Security | Input validation to prevent injection; Email format validation; Proper error messages (no stack traces in production) |
| Testing | Unit tests for all CRUD operations; Integration tests for API endpoints; Test coverage > 80% |

## Future Enhancements (Out of Scope)

| Enhancement | Status |
| --- | --- |
| User authentication/authorization | ☐ |
| Pagination for user list | ☐ |
| Search/filter capabilities | ☐ |
| Soft delete (archive instead of remove) | ☐ |
| Audit log for changes | ☐ |
| Rate limiting | ☐ |
| API versioning | ☐ |

## Dependencies

| Dependency | Purpose |
| --- | --- |
| Lapis framework | Core web framework |
| OpenResty (alpine-fat image) | Runtime (Nginx + LuaJIT) |
| LuaRocks | Package management |
| Busted | Testing framework |
| SQLite3 | Default development database |
| pgmoon (PostgreSQL driver) | PostgreSQL connectivity |
| lua-resty-mysql (MySQL driver) | MySQL connectivity |
| Lua SQL migration scripts | Database schema management across engines |

## Development Workflow

| Step | Description |
| --- | --- |
| 1 | Start Docker container |
| 2 | Edit Lua files |
| 3 | Restart container to apply changes |
| 4 | Run tests with `busted` |
| 5 | Test endpoints with `curl` or API client |

## Definition of Done

| Checklist Item | Status |
| --- | --- |
| Code implemented and follows Lua best practices | ☐ |
| Unit tests written and passing | ☐ |
| API endpoint tested manually | ☐ |
| Documentation updated | ☐ |
| Code reviewed | ☐ |
| Merged to main branch | ☐ |
