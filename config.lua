local config = require("lapis.config")

-- Development environment
config("development", {
  server = "nginx",
  code_cache = "off",  -- Enabled for hot-reload
  num_workers = "1",
  
  -- SQLite configuration (default for development)
  sqlite = {
    database = "/app/.dockerjunk/development.db"
  }
  
  -- PostgreSQL configuration (uncomment to use)
  -- postgres = {
  --   host = os.getenv("PGHOST") or "localhost",
  --   port = os.getenv("PGPORT") or "5432",
  --   user = os.getenv("PGUSER") or "postgres",
  --   password = os.getenv("PGPASSWORD") or "postgres",
  --   database = os.getenv("PGDATABASE") or "legal_api"
  -- }
  
  -- MySQL configuration (uncomment to use)
  -- mysql = {
  --   host = os.getenv("MYSQL_HOST") or "localhost",
  --   port = os.getenv("MYSQL_PORT") or "3306",
  --   user = os.getenv("MYSQL_USER") or "root",
  --   password = os.getenv("MYSQL_PASSWORD") or "root",
  --   database = os.getenv("MYSQL_DATABASE") or "legal_api"
  -- }
  
  -- Redis configuration (uncomment to use for caching/sessions)
  -- redis = {
  --   host = os.getenv("REDIS_HOST") or "localhost",
  --   port = os.getenv("REDIS_PORT") or "6379",
  --   password = os.getenv("REDIS_PASSWORD") or nil,
  --   db = os.getenv("REDIS_DB") or "0"
  -- }
})

-- Production environment
config("production", {
  server = "nginx",
  code_cache = "on",   -- Always enabled in production
  num_workers = "4",   -- Adjust based on CPU cores
  
  -- PostgreSQL configuration (recommended for production)
  postgres = {
    host = os.getenv("PGHOST") or "localhost",
    port = os.getenv("PGPORT") or "5432",
    user = os.getenv("PGUSER"),
    password = os.getenv("PGPASSWORD"),
    database = os.getenv("PGDATABASE")
  }
  
  -- Redis configuration (recommended for sessions/cache)
  -- redis = {
  --   host = os.getenv("REDIS_HOST") or "localhost",
  --   port = os.getenv("REDIS_PORT") or "6379",
  --   password = os.getenv("REDIS_PASSWORD"),
  --   db = os.getenv("REDIS_DB") or "0"
  -- }
})

-- Test environment
config("test", {
  server = "nginx",
  code_cache = "off",
  num_workers = "1",
  
  -- SQLite in-memory for fast tests
  sqlite = {
    database = ":memory:"
  }
})
