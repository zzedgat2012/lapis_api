local Database = require("utils.database")

local Sample = {}
local TABLE_NAME = "samples"

-- Fetch all records
function Sample.all()
  -- TODO: tailor the query for Sample
  return Database.select(("SELECT * FROM %s ORDER BY id"):format(TABLE_NAME))
end

-- Insert a new record
function Sample.create(attrs)
  -- TODO: tailor fields for Sample
  Database.insert(TABLE_NAME, attrs)
end

return Sample
