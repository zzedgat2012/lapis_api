local lapis = require("lapis")
local app = lapis.Application()
local OpenapiPresenter = require("presenters.openapi_presenter")
local SwaggerPresenter = require("presenters.swagger_presenter")
local JsonView = require("views.json_view")

-- Home route
app:get("/", function()
  return "Welcome to Lapis " .. require("lapis.version")
end)

app:get("/health", function()
  return JsonView.success({ status = "ok" })
end)

-- OpenAPI specification
app:get("/openapi.json", function()
  return OpenapiPresenter.show()
end)

app:get("/docs", function(self)
  return SwaggerPresenter.show(self)
end)

return app

