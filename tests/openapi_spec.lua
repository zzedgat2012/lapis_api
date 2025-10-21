---@diagnostic disable: undefined-global

local assert = require("luassert")
local spec = require("openapi.spec")
local OpenapiPresenter = require("presenters.openapi_presenter")

describe("OpenAPI specification", function()
  it("uses OpenAPI 3.0", function()
    assert.are.equal("3.0.3", spec.openapi)
  end)
  it("is returned by the presenter without modification", function()
    local response = OpenapiPresenter.show()
    assert.are.equal(200, response.status)
    assert.are.equal(spec, response.json)
  end)
end)
