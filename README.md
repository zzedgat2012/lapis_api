# Lapis API Template

Template repository for building REST APIs with [Lapis](https://leafo.net/lapis/) framework running on OpenResty in Docker.

## 🚀 Quick Start

```bash
# Clone and start
git clone <your-repo-url>
cd legal_api
make start    # docker compose up -d
make migrate  # lapis migrate inside the container
```

Access: <http://localhost:8080>

## 📋 What's Included

- ✅ Lapis framework on OpenResty (Alpine)
- ✅ Docker Compose setup for development
- ✅ SQLite for development (PostgreSQL recommended for production)
- ✅ Hot-reload enabled (`lua_code_cache off`)
- ✅ Example CRUD API for users
- ✅ Busted test framework
- ✅ Organized project structure

## 📁 Project Structure

```
legal_api/
├── app.lua              # Main application and routes
├── config.lua           # Environment configurations
├── models.lua           # Model loader
├── nginx.conf           # OpenResty configuration
├── Dockerfile           # Container build definition
├── docker-compose.yml   # Docker orchestration
├── project-requirements.md  # User stories and requirements
├── docs/                # Technical documentation
│   ├── 1. Development.md   # Development guide
│   ├── 2. Api.md           # API documentation
│   ├── 3. Database.md      # Database configuration
│   └── 4. Testing.md       # Testing guide
├── tests/               # Busted test specs
│   └── user_spec.lua
├── models/              # Database models (create as needed)
└── .vscode/             # VSCode/Copilot settings
    └── copilot-instructions.md
```

## 🔧 Development

### Make changes to code

1. Edit `.lua` files
2. Changes apply automatically (hot-reload enabled)
3. Test: `curl http://localhost:8080/users`

**Note**: Hot-reload works because `lua_code_cache off` is enabled in development. Data persists in SQLite database.

### Run tests

```bash
make test
```

### View logs

```bash
make logs
```

### Handy Make targets

```bash
make start    # start containers in background
make stop     # stop containers
make restart  # restart containers
make migrate  # apply database migrations (Lapis)
make rollback # rollback the most recent migrations (scaffold-generated)
make test     # run busted test suite
make logs     # tail application logs
make shell    # open shell inside the web container
make clean    # stop and remove containers + volumes
make model NAME=Invoice           # generate model + migration
make model NAME=Invoice SCAFFOLD=crud  # generate CRUD presenter/view/test stubs + routes + OpenAPI docs
```

> **Tip:** `make model` also accepts `ARGS="--name Invoice --scaffold crud"` if you prefer
passing raw flags directly to the generator script.

## 💾 Database

**Development**: MySQL by default (managed by Docker Compose)  
**Production**: PostgreSQL recommended (MySQL optional)

Configuration is driven by the `DB_CONNECTION` environment variable (`mysql`, `postgres`, or `sqlite`). Example:

```bash
# Default MySQL workflow
export DB_CONNECTION=mysql
docker compose up -d
make migrate

# Switch to PostgreSQL (enables the postgres profile and service)
export DB_CONNECTION=postgres
export PGHOST=postgres
export PGUSER=postgres
export PGPASSWORD=postgres
export PGDATABASE=legal_api
docker compose --profile postgres up -d web postgres
docker compose --profile postgres exec web lapis migrate

# Back to SQLite only
unset DB_CONNECTION PGHOST PGUSER PGPASSWORD PGDATABASE
docker compose stop mysql
docker compose up -d web

# Restore MySQL defaults later
export DB_CONNECTION=mysql
docker compose up -d mysql web
```

The `docker-compose.yml` file runs MySQL by default and ships an optional `postgres` profile for production parity. See `docs/3. Database.md` for deep-dive configuration, migrations, and troubleshooting tips.

## 📚 Documentation

1. [Development Guide](docs/1.%20Development.md) - Setup, workflow, best practices
2. [API Reference](docs/2.%20Api.md) - Endpoint documentation
3. [Database Guide](docs/3.%20Database.md) - SQLite, PostgreSQL, MySQL, Redis setup
4. [Testing Guide](docs/4.%20Testing.md) - How to write and run tests
5. [Project Requirements](project-requirements.md) - User stories and features

## 🎯 Example API

```bash
# List users
curl http://localhost:8080/users

# Create user
curl -X POST http://localhost:8080/users \
  -d "name=John&email=john@example.com"

# Get user
curl http://localhost:8080/users/1

# Update user
curl -X PUT http://localhost:8080/users/1 \
  -d "name=John Updated"

# Delete user
curl -X DELETE http://localhost:8080/users/1

# Fetch OpenAPI spec
curl http://localhost:8080/openapi.json
```

## 🛠️ Tech Stack

- **Framework**: [Lapis](https://leafo.net/lapis/)
- **Web Server**: [OpenResty](https://openresty.org/)
- **Language**: Lua 5.1 / LuaJIT
- **Container**: Docker + Docker Compose
- **Testing**: [Busted](https://olivinelabs.com/busted/)
- **Database (dev)**: MySQL by default, switchable to PostgreSQL/SQLite via `DB_CONNECTION`
- **Database (prod)**: PostgreSQL (recommended) or MySQL when required

## 📖 Resources

- [Lapis Documentation](https://leafo.net/lapis/reference.html)
- [OpenResty Documentation](https://openresty-reference.readthedocs.io/)
- [Lua 5.1 Reference](https://www.lua.org/manual/5.1/)

## 📝 License

MIT
