local db = require("lapis.db")
local schema = require("lapis.db.schema")
local types = schema.types

local migration = {}

function migration.up()
  -- TODO: adjust columns and indexes for Sample
  local ok, err = pcall(schema.create_table, "samples", {
    { "id", types.id },
    { "name", types.varchar({ length = 255 }) },
    { "created_at", types.timestamp({ default = db.raw("CURRENT_TIMESTAMP") }) },
    { "updated_at", types.timestamp({ default = db.raw("CURRENT_TIMESTAMP") }) }
  }, {
    if_not_exists = true
  })
  if not ok and err and not err:match("exists") then
    error(err)
  end

  -- Example: schema.create_index("samples", "name", { unique = true })
end

function migration.down()
  -- TODO: adjust rollback behavior if you add indexes or related data
  local ok, err = pcall(schema.drop_table, "samples")
  if not ok and err and not err:match("exist") then
    error(err)
  end
end

return setmetatable(migration, {
  __call = function(_, ...)
    return migration.up()
  end
})
