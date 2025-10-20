---@diagnostic disable: undefined-global

local assert = require("luassert")
local SwaggerPresenter = require("presenters.swagger_presenter")

describe("Swagger UI presenter", function()
  it("returns HTML with swagger-ui assets", function()
    local response = SwaggerPresenter.show()

    assert.are.equal(200, response.status)
    assert.is_false(response.layout)
    assert.is_false(response.render)
    assert.are.same("text/html; charset=utf-8", response.headers["Content-Type"])
    assert.are.same("text/html; charset=utf-8", response.content_type)
    assert.is_string(response.content)
    assert.is_true(response.content:find("swagger%-ui") ~= nil)
    assert.is_true(response.content:find("/openapi%.json") ~= nil)
  end)
end)
