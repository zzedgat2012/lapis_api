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
      url = "https://github.com/zzedgat2012/lapis_api"
    }
  },
  servers = {
    {
      url = load_env("OPENAPI_SERVER_URL", "http://localhost:8080"),
      description = "Development server"
    }
  },
  tags = {},
  paths = {},
  components = {
    schemas = {
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
      }
    },
    parameters = {}
  }
}

return spec
