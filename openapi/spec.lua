local function load_env(name, fallback)
  local value = os.getenv(name)
  if value and value ~= "" then
    return value
  end
  return fallback
end

local function build_version()
  return load_env("OPENAPI_VERSION", "1.0.0")
end

local spec = {
  openapi = "3.0.3",
  info = {
    title = "Legal API",
    description = "REST API for managing legal entities built with Lapis",
    version = build_version(),
    contact = {
      name = "Legal API",
      url = "https://github.com/zzedgat2012/lapis_api",
    }
  },
  servers = {
    {
      url = load_env("OPENAPI_SERVER_URL", "http://localhost:8080"),
      description = "Development server"
    }
  },
  tags = {
    { name = "Users", description = "User management endpoints" }
  },
  paths = {},
  components = {
    schemas = {
      User = {
        type = "object",
        required = { "id", "name", "email", "created_at", "updated_at" },
        properties = {
          id = { type = "integer", format = "int64", example = 1 },
          name = { type = "string", example = "Alice Smith" },
          email = { type = "string", format = "email", example = "alice@example.com" },
          created_at = { type = "string", format = "date-time", example = "2025-01-01T12:34:56Z" },
          updated_at = { type = "string", format = "date-time", example = "2025-01-01T12:34:56Z" }
        }
      },
      UserInput = {
        type = "object",
        properties = {
          name = { type = "string", example = "Alice Smith" },
          email = { type = "string", format = "email", example = "alice@example.com" }
        },
        required = { "name", "email" }
      },
      UserUpdateInput = {
        type = "object",
        properties = {
          name = { type = "string" },
          email = { type = "string", format = "email" }
        }
      },
      SuccessResponse = {
        type = "object",
        properties = {
          success = { type = "boolean", example = true }
        },
        required = { "success" }
      },
      ErrorResponse = {
        type = "object",
        required = { "success", "error" },
        properties = {
          success = { type = "boolean", example = false },
          error = { type = "string", example = "Not found" }
        }
      },
      UsersListResponse = {
        type = "object",
        required = { "success", "count", "users" },
        properties = {
          success = { type = "boolean", example = true },
          count = { type = "integer", format = "int32", example = 1 },
          users = {
            type = "array",
            items = { ["$ref"] = "#/components/schemas/User" }
          }
        }
      },
      UserItemResponse = {
        allOf = {
          { ["$ref"] = "#/components/schemas/SuccessResponse" },
          {
            type = "object",
            required = { "user" },
            properties = {
              user = { ["$ref"] = "#/components/schemas/User" }
            }
          }
        }
      },
      UserDeletedResponse = {
        allOf = {
          { ["$ref"] = "#/components/schemas/SuccessResponse" },
          {
            type = "object",
            properties = {
              message = { type = "string", example = "User deleted successfully" }
            }
          }
        }
      }
    },
    parameters = {
      UserId = {
        name = "id",
        ["in"] = "path",
        required = true,
        schema = { type = "integer", format = "int64" },
        description = "Unique identifier of the user"
      }
    }
  }
}

spec.paths["/users"] = {
  get = {
    tags = { "Users" },
    summary = "List users",
    description = "Returns a pageless list of users",
    responses = {
      ["200"] = {
        description = "Successful response",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/UsersListResponse" }
          }
        }
      }
    }
  },
  post = {
    tags = { "Users" },
    summary = "Create user",
    description = "Creates a new user with name and email",
    requestBody = {
      required = true,
      content = {
        ["application/json"] = {
          schema = { ["$ref"] = "#/components/schemas/UserInput" }
        },
        ["application/x-www-form-urlencoded"] = {
          schema = { ["$ref"] = "#/components/schemas/UserInput" }
        }
      }
    },
    responses = {
      ["201"] = {
        description = "User created",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/UserItemResponse" }
          }
        }
      },
      ["400"] = {
        description = "Invalid input",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/ErrorResponse" }
          }
        }
      },
      ["409"] = {
        description = "Email already exists",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/ErrorResponse" }
          }
        }
      }
    }
  }
}

spec.paths["/users/{id}"] = {
  get = {
    tags = { "Users" },
    summary = "Get user",
    description = "Returns a user by ID",
    parameters = {
      { ["$ref"] = "#/components/parameters/UserId" }
    },
    responses = {
      ["200"] = {
        description = "User found",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/UserItemResponse" }
          }
        }
      },
      ["400"] = {
        description = "Invalid ID",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/ErrorResponse" }
          }
        }
      },
      ["404"] = {
        description = "User not found",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/ErrorResponse" }
          }
        }
      }
    }
  },
  put = {
    tags = { "Users" },
    summary = "Update user",
    description = "Updates user details",
    parameters = {
      { ["$ref"] = "#/components/parameters/UserId" }
    },
    requestBody = {
      required = true,
      content = {
        ["application/json"] = {
          schema = { ["$ref"] = "#/components/schemas/UserUpdateInput" }
        },
        ["application/x-www-form-urlencoded"] = {
          schema = { ["$ref"] = "#/components/schemas/UserUpdateInput" }
        }
      }
    },
    responses = {
      ["200"] = {
        description = "User updated",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/UserItemResponse" }
          }
        }
      },
      ["400"] = {
        description = "Invalid payload",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/ErrorResponse" }
          }
        }
      },
      ["404"] = {
        description = "User not found",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/ErrorResponse" }
          }
        }
      },
      ["409"] = {
        description = "Email already exists",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/ErrorResponse" }
          }
        }
      }
    }
  },
  delete = {
    tags = { "Users" },
    summary = "Delete user",
    description = "Deletes a user by ID",
    parameters = {
      { ["$ref"] = "#/components/parameters/UserId" }
    },
    responses = {
      ["200"] = {
        description = "User deleted",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/UserDeletedResponse" }
          }
        }
      },
      ["404"] = {
        description = "User not found",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/ErrorResponse" }
          }
        }
      }
    }
  }
}

return spec
