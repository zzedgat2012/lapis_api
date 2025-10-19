-- utils/database.lua
local db = require("lapis.db")

local Database = {}

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
  local success, res = db.insert(table_name, data, "id")
  if success then
    return res -- Retorna o ID
  end
  return nil, res -- Retorna nil e a mensagem de erro
end

-- Função para atualizar registros existentes.
-- 'data' é uma tabela com os novos valores (ex: { name = "Novo Nome" })
-- 'where' é a condição (ex: { id = 1 })
function Database.update(table_name, data, where)
  return db.update(table_name, data, where)
end

-- Função para deletar registros.
-- 'where' é a condição (ex: { email = "email@exemplo.com" })
function Database.delete(table_name, where)
  return db.delete(table_name, where)
end

return Database