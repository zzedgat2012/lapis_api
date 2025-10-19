#!/bin/sh
# docker-entrypoint.sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Define o caminho para o arquivo de banco de dados e o schema
DB_FILE="/app/.dockerjunk/development.db"
SCHEMA_FILE="/app/schema.sql"

# Cria o diretório se ele não existir
mkdir -p /app/.dockerjunk

# Verifica se o arquivo do banco de dados já existe.
# Se não existir, cria-o e inicializa com o schema.
if [ ! -f "$DB_FILE" ]; then
  echo "Database file not found. Creating and initializing database..."
  sqlite3 "$DB_FILE" < "$SCHEMA_FILE"
  echo "Database initialized successfully."
else
  echo "Database file already exists."
fi

# Executa o comando principal do container (inicia o OpenResty)
exec "$@"
