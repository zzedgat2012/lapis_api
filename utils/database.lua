-- utils/database.lua
local db = require("lapis.db")
local lapis_config = require("lapis.config")

local Database = {}

local function detect_engine()
  local cfg = lapis_config.get()
  if cfg and cfg.postgres then
    return "postgres"
  end
  if cfg and cfg.mysql then
    return "mysql"
  end
  return "sqlite"
end

local ACTIVE_ENGINE = detect_engine()

local NOW_EXPRESSIONS = {
  postgres = "NOW()",
  mysql = "CURRENT_TIMESTAMP",
  sqlite = "CURRENT_TIMESTAMP"
}

local function raw_now()
  return db.raw(NOW_EXPRESSIONS[ACTIVE_ENGINE] or "CURRENT_TIMESTAMP")
end

function Database.engine()
  return ACTIVE_ENGINE
end

-- Função para executar queries SELECT genéricas.
-- Retorna uma tabela com as linhas encontradas.
function Database.select(sql, ...)
  local results, err = db.query(sql, ...)
  if not results then
    -- Em caso de erro, você pode querer logar o erro.
    -- print("Erro na query:", err)
    return nil, err
  end
  return results
end

-- Função para inserir um novo registro em uma tabela.
-- Retorna o ID do último registro inserido em caso de sucesso.
function Database.insert(table_name, data)
  local returning = ACTIVE_ENGINE == "postgres" and "id" or nil
  local success, res = db.insert(table_name, data, returning)
  if success then
    if returning and type(res) == "table" then
      local row = res[1]
      if row and row.id then
        return row.id
      end
    end
    if type(res) == "table" and res.insert_id then
      return res.insert_id
    end
    return res
  end
  return nil, res -- Retorna nil e a mensagem de erro
end

-- Função para atualizar registros existentes.
-- 'data' é uma tabela com os novos valores (ex: { name = "Novo Nome" })
-- 'where' é a condição (ex: { id = 1 })
function Database.update(table_name, data, where)
  local payload = {}

  for key, value in pairs(data or {}) do
    payload[key] = value
  end

  payload.updated_at = raw_now()

  return db.update(table_name, payload, where)
end

-- Função para deletar registros.
-- 'where' é a condição (ex: { email = "email@exemplo.com" })
function Database.delete(table_name, where)
  return db.delete(table_name, where)
end

return Database