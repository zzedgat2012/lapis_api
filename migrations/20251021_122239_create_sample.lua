local db = require("lapis.db")
local schema = require("lapis.db.schema")
local types = schema.types

local migration = {}

local function schema_type(name)
  return rawget(schema.types, name)
end

local id_type = schema_type("serial") or schema_type("id") or schema_type("integer")
local timestamp_type = schema_type("timestamp") or schema_type("time") or schema_type("datetime")

local function timestamp_column()
  if timestamp_type then
    return timestamp_type({ default = db.raw("CURRENT_TIMESTAMP") })
  end
  return "timestamp DEFAULT CURRENT_TIMESTAMP"
end

function migration.up()
  -- TODO: adjust columns and indexes for Sample
  local ok, err = pcall(schema.create_table, "samples", {
    { "id", id_type },
    { "name", types.varchar({ length = 255 }) },
    { "created_at", timestamp_column() },
    { "updated_at", timestamp_column() }
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
