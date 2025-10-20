---@diagnostic disable: undefined-global

local assert = require("luassert")
local spec = require("openapi.spec")
local OpenapiPresenter = require("presenters.openapi_presenter")

describe("OpenAPI specification", function()
  it("uses OpenAPI 3.0", function()
    assert.are.equal("3.0.3", spec.openapi)
  end)

  it("describes the users collection endpoint", function()
    local users_path = spec.paths["/users"]
    assert.is_table(users_path)
    assert.is_table(users_path.get)
    assert.is_table(users_path.post)
  end)

  it("describes the user item endpoint", function()
    local user_path = spec.paths["/users/{id}"]
    assert.is_table(user_path)
    assert.is_table(user_path.get)
    assert.is_table(user_path.put)
    assert.is_table(user_path.delete)

    local parameters = user_path.get.parameters
    assert.is_table(parameters)
    assert.is_table(parameters[1])
    assert.are.equal("#/components/parameters/UserId", parameters[1]["$ref"])
  end)

  it("includes schemas for user responses", function()
    local schemas = spec.components.schemas
    assert.is_table(schemas.User)
    assert.is_table(schemas.UserItemResponse)
    assert.is_table(schemas.UsersListResponse)
  end)

  it("is returned by the presenter without modification", function()
    local response = OpenapiPresenter.show()
    assert.are.equal(200, response.status)
    assert.are.equal(spec, response.json)
  end)
end)
