# Project Requirements - Legal API

## Overview

REST API for managing legal entities using Lapis framework on OpenResty.

## User Stories

### Epic: User Management CRUD

#### US-001: List All Users
**As a** API consumer  
**I want to** retrieve a list of all users  
**So that** I can display them in my application

**Acceptance Criteria:**
- GET `/users` returns JSON array of all users
- Response includes user id, name, email, created_at
- Returns 200 OK status code
- Returns empty array if no users exist

---

#### US-002: Get User by ID
**As a** API consumer  
**I want to** retrieve a specific user by their ID  
**So that** I can display user details

**Acceptance Criteria:**
- GET `/users/:id` returns user data for valid ID
- Returns 404 Not Found for non-existent ID
- Returns 400 Bad Request for invalid ID format
- Response includes all user fields

---

#### US-003: Create New User
**As a** API consumer  
**I want to** create a new user  
**So that** I can add users to the system

**Acceptance Criteria:**
- POST `/users` with name and email creates user
- Returns 201 Created on success
- Returns 400 Bad Request if name is missing
- Returns 400 Bad Request if email is missing
- Returns 409 Conflict if email already exists
- Auto-generates unique ID
- Auto-sets created_at timestamp

---

#### US-004: Update Existing User
**As a** API consumer  
**I want to** update user information  
**So that** I can keep user data current

**Acceptance Criteria:**
- PUT `/users/:id` updates user fields
- Can update name, email, or both
- Returns 200 OK with updated user
- Returns 404 Not Found for non-existent ID
- Returns 409 Conflict if new email already exists
- Sets updated_at timestamp

---

#### US-005: Delete User
**As a** API consumer  
**I want to** remove a user from the system  
**So that** I can clean up inactive users

**Acceptance Criteria:**
- DELETE `/users/:id` removes user
- Returns 200 OK with success message
- Returns 404 Not Found for non-existent ID
- User is permanently removed from database

---

## Technical Requirements

### Database

**Development Environment:**
- Use SQLite for quick setup and testing
- In-memory storage (data resets on restart)
- No migrations needed for prototype

**Production Environment:**
- Use PostgreSQL for data persistence
- Implement proper migrations
- Connection pooling recommended

### Validation Rules

**User Model:**
- `name`: Required, non-empty string
- `email`: Required, non-empty string, must be unique
- `id`: Auto-generated, positive integer
- `created_at`: Auto-generated, Unix timestamp
- `updated_at`: Auto-set on update, Unix timestamp

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

- `200 OK`: Successful GET, PUT, DELETE
- `201 Created`: Successful POST
- `400 Bad Request`: Invalid input
- `404 Not Found`: Resource not found
- `409 Conflict`: Duplicate resource

## Non-Functional Requirements

### Performance
- Response time < 100ms for simple queries
- Support at least 100 concurrent requests

### Security
- Input validation to prevent injection
- Email format validation
- Proper error messages (no stack traces in production)

### Testing
- Unit tests for all CRUD operations
- Integration tests for API endpoints
- Test coverage > 80%

## Future Enhancements (Out of Scope)

- [ ] User authentication/authorization
- [ ] Pagination for user list
- [ ] Search/filter capabilities
- [ ] Soft delete (archive instead of remove)
- [ ] Audit log for changes
- [ ] Rate limiting
- [ ] API versioning

## Dependencies

- Lapis framework (latest stable)
- OpenResty (alpine-fat image)
- LuaRocks for package management
- Busted for testing
- SQLite3 (development)
- PostgreSQL driver (production)

## Development Workflow

1. Start Docker container
2. Edit Lua files
3. Restart container to apply changes
4. Run tests with `busted`
5. Test endpoints with `curl` or API client

## Definition of Done

A user story is considered done when:
- [ ] Code implemented and follows Lua best practices
- [ ] Unit tests written and passing
- [ ] API endpoint tested manually
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] Merged to main branch
