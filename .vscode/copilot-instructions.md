# GitHub Copilot Instructions - Lapis API Project

## Project Context

This is a REST API built with the Lapis web framework running on OpenResty (nginx + LuaJIT). The project uses Docker for containerization and follows Lua best practices.

## Framework: Lapis

### Key Concepts

**Lapis** is a web framework written in MoonScript/Lua that runs on OpenResty.

- **Application**: Defined using `lapis.Application()`
- **Routes**: Use `app:get()`, `app:post()`, `app:put()`, `app:delete()`
- **Request Context**: Available as `self` in route handlers
- **Parameters**: Access via `self.params.field_name`
- **JSON Responses**: Return `{ json = { data } }`
- **HTTP Status**: Use `status` key, e.g., `{ status = 404, json = { error = "..." } }`

### Route Definition Pattern

```lua
app:get("/path/:param", function(self)
  local param_value = self.params.param
  return { json = { result = "..." } }
end)

app:post("/path", function(self)
  local data = self.params
  -- validate and process
  return { status = 201, json = { created = true } }
end)
```

### Database (Development)

Currently using **in-memory global tables** for simplicity:
- Use `_G.table_name` for persistence across requests (with `lua_code_cache on`)
- For production, integrate `lapis.db.model` with PostgreSQL

### Models Pattern (Future)

```lua
local Model = require("lapis.db.model").Model
local Users = Model:extend("users")
return Users
```

## Code Style Guidelines

### Lua Best Practices

1. **Local Variables**: Always use `local` for variables
2. **Naming**: 
   - `snake_case` for variables and functions
   - `PascalCase` for classes/models
3. **Tables**: Use comma-separated key-value pairs
4. **Functions**: Prefer `local function name()` over `local name = function()`
5. **Return Early**: Exit functions early on validation failures

### Error Handling

```lua
-- Validation
if not data then
  return { status = 400, json = { success = false, error = "Message" } }
end

-- Not Found
if not resource then
  return { status = 404, json = { success = false, error = "Not found" } }
end

-- Conflict
if duplicate then
  return { status = 409, json = { success = false, error = "Already exists" } }
end
```

### Response Format

**Always use consistent response structure:**

```lua
-- Success
return { 
  json = { 
    success = true, 
    data = result 
  } 
}

-- Error
return { 
  status = 400,
  json = { 
    success = false, 
    error = "Error message" 
  } 
}
```

## OpenResty / nginx Configuration

### nginx.conf Structure

```nginx
worker_processes 1;
daemon off;  # Required for Docker

http {
  server {
    listen 80;
    lua_code_cache on;  # off for hot-reload, on for production
    
    location / {
      content_by_lua_block {
        require("lapis").serve("app")
      }
    }
  }
}
```

## Testing with Busted

### Test File Structure (`tests/*_spec.lua`)

```lua
describe("Feature", function()
  before_each(function()
    -- Setup
  end)
  
  it("should do something", function()
    local result = some_function()
    assert.are.equal(expected, result)
  end)
  
  it("should handle errors", function()
    assert.has_error(function()
      error_function()
    end)
  end)
end)
```

### Common Assertions

- `assert.are.equal(expected, actual)`
- `assert.is_true(condition)`
- `assert.is_nil(value)`
- `assert.has_error(function)`

## Docker Development Workflow

1. **Edit code** in `app.lua`, `models.lua`, etc.
2. **Restart container**: `docker compose restart`
3. **Test endpoint**: `curl http://localhost:8080/endpoint`
4. **Run tests**: `docker compose exec web busted`
5. **View logs**: `docker compose logs -f`

## Common Patterns

### CRUD Route Template

```lua
-- List all
app:get("/resources", function(self)
  return { json = { success = true, resources = _G.resources } }
end)

-- Get one
app:get("/resources/:id", function(self)
  local id = tonumber(self.params.id)
  if not id then
    return { status = 400, json = { success = false, error = "Invalid ID" } }
  end
  
  local resource = _G.resources[id]
  if not resource then
    return { status = 404, json = { success = false, error = "Not found" } }
  end
  
  return { json = { success = true, resource = resource } }
end)

-- Create
app:post("/resources", function(self)
  -- Validation
  if not self.params.required_field then
    return { status = 400, json = { success = false, error = "Field required" } }
  end
  
  -- Create
  local new_resource = {
    id = get_next_id(),
    field = self.params.field,
    created_at = os.time()
  }
  
  _G.resources[new_resource.id] = new_resource
  return { status = 201, json = { success = true, resource = new_resource } }
end)

-- Update
app:put("/resources/:id", function(self)
  local id = tonumber(self.params.id)
  local resource = _G.resources[id]
  
  if not resource then
    return { status = 404, json = { success = false, error = "Not found" } }
  end
  
  -- Update fields
  if self.params.field then
    resource.field = self.params.field
  end
  resource.updated_at = os.time()
  
  return { json = { success = true, resource = resource } }
end)

-- Delete
app:delete("/resources/:id", function(self)
  local id = tonumber(self.params.id)
  
  if not _G.resources[id] then
    return { status = 404, json = { success = false, error = "Not found" } }
  end
  
  _G.resources[id] = nil
  return { json = { success = true, message = "Deleted" } }
end)
```

## File Organization

```
app.lua         - Main application, route definitions
config.lua      - Environment-specific configuration
models.lua      - Model auto-loader (loads from models/ directory)
models/         - Individual model files (User, Post, etc.)
tests/          - Busted test specifications
nginx.conf      - OpenResty configuration
```

## Environment Configuration

```lua
-- config.lua
local config = require("lapis.config")

config("development", {
  server = "nginx",
  code_cache = "on",  -- or "off" for hot-reload
  num_workers = "1",
  port = "80"
})

config("production", {
  code_cache = "on",
  num_workers = "4",
  postgres = {
    host = os.getenv("DB_HOST"),
    user = os.getenv("DB_USER"),
    password = os.getenv("DB_PASSWORD"),
    database = os.getenv("DB_NAME")
  }
})
```

## When Helping with Code

1. **Always use `local`** for variables
2. **Validate input** before processing
3. **Return proper HTTP status codes**
4. **Use consistent JSON response format**
5. **Add comments for complex logic**
6. **Follow the CRUD pattern** shown above
7. **Write tests** for new features
8. **Check for `nil`** before accessing table fields

## Resources

- [Lapis Reference](https://leafo.net/lapis/reference.html)
- [Lua 5.1 Manual](https://www.lua.org/manual/5.1/)
- [Busted Documentation](https://olivinelabs.com/busted/)
- [OpenResty Best Practices](https://github.com/openresty/lua-nginx-module#readme)
