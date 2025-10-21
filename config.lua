local config = require("lapis.config")

local function normalize_connection()
  local value = os.getenv("DB_CONNECTION")
  if not value or value == "" then
    return nil
  end
  return value:lower()
end

local function database_block(opts)
  local connection = normalize_connection() or opts.default_connection
  local settings = {
    server = "nginx",
    code_cache = opts.code_cache or "off",
    num_workers = opts.num_workers or "1"
  }

  if connection == "postgres" then
    settings.postgres = {
      host = os.getenv("PGHOST") or "postgres",
      port = os.getenv("PGPORT") or "5432",
      user = os.getenv("PGUSER") or "postgres",
      password = os.getenv("PGPASSWORD") or "postgres",
      database = os.getenv("PGDATABASE") or "legal_api"
    }
  elseif connection == "mysql" then
    settings.mysql = {
      host = os.getenv("MYSQL_HOST") or "mysql",
      port = os.getenv("MYSQL_PORT") or "3306",
      user = os.getenv("MYSQL_USER") or "lapis",
      password = os.getenv("MYSQL_PASSWORD") or "lapis",
      database = os.getenv("MYSQL_DATABASE") or "legal_api"
    }
  else
    settings.sqlite = {
      database = opts.sqlite_db or "/app/.dockerjunk/development.db"
    }
  end

  return settings
end

-- Development environment
config("development", database_block({
  default_connection = "postgres", -- use postgres, mysql or sqlite
  code_cache = "off",
  num_workers = "1",
  sqlite_db = "/app/.dockerjunk/development.db"
}))

-- Production environment
config("production", database_block({
  default_connection = "postgres",
  code_cache = "on",
  num_workers = "4"
}))

-- Test environment
config("test", database_block({
  default_connection = "sqlite",
  code_cache = "off",
  num_workers = "1",
  sqlite_db = ":memory:"
}))
