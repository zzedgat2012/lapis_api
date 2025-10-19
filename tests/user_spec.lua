-- tests/user_spec.lua
-- Example tests for User CRUD operations
--
-- Note: These tests demonstrate testing patterns for the user service.
-- Since we're using in-memory global storage (_G.users), these tests
-- require the application to be running OR you need to refactor business
-- logic into separate modules for unit testing.
--
-- For now, this serves as a template. See docs/TESTING.md for details.

describe("User Service", function()
  
  before_each(function()
    -- Reset global state before each test
    _G.users = {}
    _G.next_id = 1
  end)
  
  describe("In-memory storage", function()
    it("should initialize with empty users table", function()
      assert.is_table(_G.users)
      assert.are.equal(0, next(_G.users) and 1 or 0)
    end)
    
    it("should initialize next_id to 1", function()
      assert.are.equal(1, _G.next_id)
    end)
  end)
  
  describe("Create user", function()
    it("should create user with valid data", function()
      local user = {
        id = _G.next_id,
        name = "Alice Smith",
        email = "alice@example.com"
      }
      
      _G.users[_G.next_id] = user
      _G.next_id = _G.next_id + 1
      
      assert.are.equal(1, user.id)
      assert.are.equal("Alice Smith", user.name)
      assert.are.equal("alice@example.com", user.email)
      assert.are.equal(2, _G.next_id)
    end)
    
    it("should increment next_id after creation", function()
      local initial_id = _G.next_id
      
      _G.users[_G.next_id] = { id = _G.next_id, name = "User", email = "user@example.com" }
      _G.next_id = _G.next_id + 1
      
      assert.are.equal(initial_id + 1, _G.next_id)
    end)
  end)
  
  describe("Email validation", function()
    it("should detect duplicate emails", function()
      _G.users[1] = { id = 1, name = "Alice", email = "alice@example.com" }
      _G.users[2] = { id = 2, name = "Bob", email = "bob@example.com" }
      
      local new_email = "alice@example.com"
      local is_duplicate = false
      
      for _, user in pairs(_G.users) do
        if user.email == new_email then
          is_duplicate = true
          break
        end
      end
      
      assert.is_true(is_duplicate)
    end)
    
    it("should allow unique emails", function()
      _G.users[1] = { id = 1, name = "Alice", email = "alice@example.com" }
      
      local new_email = "charlie@example.com"
      local is_duplicate = false
      
      for _, user in pairs(_G.users) do
        if user.email == new_email then
          is_duplicate = true
          break
        end
      end
      
      assert.is_false(is_duplicate)
    end)
  end)
  
  describe("Read operations", function()
    before_each(function()
      _G.users[1] = { id = 1, name = "Alice", email = "alice@example.com" }
      _G.users[2] = { id = 2, name = "Bob", email = "bob@example.com" }
      _G.next_id = 3
    end)
    
    it("should list all users", function()
      local count = 0
      for _ in pairs(_G.users) do
        count = count + 1
      end
      
      assert.are.equal(2, count)
    end)
    
    it("should get user by id", function()
      local user_id = 1
      local user = _G.users[user_id]
      
      assert.is_not_nil(user)
      assert.are.equal("Alice", user.name)
      assert.are.equal("alice@example.com", user.email)
    end)
    
    it("should return nil for non-existent id", function()
      local user = _G.users[999]
      assert.is_nil(user)
    end)
  end)
  
  describe("Update operations", function()
    before_each(function()
      _G.users[1] = { id = 1, name = "Alice", email = "alice@example.com" }
    end)
    
    it("should update user name", function()
      local user_id = 1
      _G.users[user_id].name = "Alice Johnson"
      
      assert.are.equal("Alice Johnson", _G.users[user_id].name)
      assert.are.equal("alice@example.com", _G.users[user_id].email)
    end)
    
    it("should update user email", function()
      local user_id = 1
      _G.users[user_id].email = "alice.johnson@example.com"
      
      assert.are.equal("Alice", _G.users[user_id].name)
      assert.are.equal("alice.johnson@example.com", _G.users[user_id].email)
    end)
  end)
  
  describe("Delete operations", function()
    before_each(function()
      _G.users[1] = { id = 1, name = "Alice", email = "alice@example.com" }
      _G.users[2] = { id = 2, name = "Bob", email = "bob@example.com" }
    end)
    
    it("should delete user by id", function()
      local user_id = 1
      _G.users[user_id] = nil
      
      assert.is_nil(_G.users[user_id])
    end)
    
    it("should maintain other users after deletion", function()
      _G.users[1] = nil
      
      assert.is_nil(_G.users[1])
      assert.is_not_nil(_G.users[2])
      assert.are.equal("Bob", _G.users[2].name)
    end)
  end)
  
end)

--[[
  INTEGRATION TESTS (Requires running server)
  
  To test actual HTTP endpoints:
  1. Start the server: docker compose up
  2. Create integration test files separately
  
  See docs/4. Testing.md for integration testing examples.
--]]
