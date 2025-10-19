local db = require("lapis.db")

return function()
  local existing = db.query("SELECT 1 FROM users WHERE email = ? LIMIT 1", "admin@example.com")

  if not existing[1] then
    db.insert("users", {
      name = "Admin User",
      email = "admin@example.com"
    })
  end
end
