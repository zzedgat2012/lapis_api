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

## Technical Requirements

### Database

| Environment | Requirements |
| --- | --- |
| Development | Use SQLite for quick setup and testing; In-memory storage (data resets on restart); No migrations needed for prototype |
| Production | Use PostgreSQL for data persistence; Implement proper migrations; Connection pooling recommended |

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
| SQLite3 | Development database |
| PostgreSQL driver | Production database connectivity |

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
