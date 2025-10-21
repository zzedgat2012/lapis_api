local db = require("lapis.db")

local migration = {}

function migration.up()
  local existing = db.query("SELECT 1 FROM users WHERE email = ? LIMIT 1", "admin@example.com")

  if not existing[1] then
    db.insert("users", {
      name = "Admin User",
      email = "admin@example.com"
    })
  end
end

function migration.down()
  db.query("DELETE FROM users WHERE email = ?", "admin@example.com")
end

return setmetatable(migration, {
  __call = function(_, ...)
    return migration.up()
  end
})
