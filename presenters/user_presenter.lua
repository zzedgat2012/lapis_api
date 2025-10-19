local User = require("models.user")
local View = require("views.json_view")

local UserPresenter = {}

-- List all users
function UserPresenter.index()
  local users = User.all()
  return View.success({
    count = #users,
    users = users
  })
end

-- Show single user
function UserPresenter.show(user_id)
  local id = tonumber(user_id)
  
  if not id then
    return View.error("Invalid user ID", 400)
  end
  
  local user = User.find(id)
  
  if not user then
    return View.error("User not found", 404)
  end
  
  return View.success({ user = user })
end

-- Create new user
function UserPresenter.create(params)
  local name = params.name
  local email = params.email
  
  -- Validation
  if not name or not email then
    return View.error("Name and email are required", 400)
  end
  
  -- Check for duplicate email
  local existing = User.find_by_email(email)
  if existing then
    return View.error("Email already exists", 409)
  end
  
  -- Create user
  local user = User.create(name, email)
  
  return View.success({ user = user }, 201)
end

-- Update user
function UserPresenter.update(user_id, params)
  local id = tonumber(user_id)
  
  if not id then
    return View.error("Invalid user ID", 400)
  end
  
  -- Check if user exists
  local user = User.find(id)
  if not user then
    return View.error("User not found", 404)
  end
  
  local name = params.name or user.name
  local email = params.email or user.email
  
  -- Check for duplicate email (excluding current user)
  if email ~= user.email then
    local existing = User.find_by_email(email)
    if existing then
      return View.error("Email already exists", 409)
    end
  end
  
  -- Update user
  local updated_user = User.update(id, name, email)
  
  return View.success({ user = updated_user })
end

-- Delete user
function UserPresenter.destroy(user_id)
  local id = tonumber(user_id)
  
  if not id then
    return View.error("Invalid user ID", 400)
  end
  
  -- Check if user exists
  local user = User.find(id)
  if not user then
    return View.error("User not found", 404)
  end
  
  -- Delete user
  User.delete(id)
  
  return View.success({ message = "User deleted successfully" })
end

return UserPresenter
