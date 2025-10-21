local Database = require("utils.database")

local User = {}

-- Get all users
function User.all()
  return Database.select("SELECT * FROM users ORDER BY id")
end

-- Find user by ID
function User.find(id)
  local result = Database.select("SELECT * FROM users WHERE id = ?", id)

  if not result or #result == 0 then
    return nil
  end

  return result[1]
end

-- Find user by email
function User.find_by_email(email)
  local result = Database.select("SELECT id FROM users WHERE email = ?", email)
  
  if not result or #result == 0 then
    return nil
  end
  
  return result[1]
end

-- Create new user
function User.create(name, email)
  Database.insert("users", { name = name, email = email })
  local result = Database.select("SELECT * FROM users WHERE email = ?", email)

  if not result or #result == 0 then
    return nil
  end

  return result[1]
end

-- Update user
function User.update(id, name, email)
  Database.update("users", { name = name, email = email }, { id = id })
  return User.find(id)
end

-- Delete user
function User.delete(id)
  Database.delete("users", { id = id })
  return true
end

return User
