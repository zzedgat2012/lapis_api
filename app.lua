local lapis = require("lapis")
local app = lapis.Application()
local UserPresenter = require("presenters.user_presenter")
local OpenapiPresenter = require("presenters.openapi_presenter")
local SwaggerPresenter = require("presenters.swagger_presenter")

-- Home route
app:get("/", function()
  return "Welcome to Lapis " .. require("lapis.version")
end)

-- User routes
app:get("/users", function(self)
  return UserPresenter.index()
end)

app:get("/users/:id", function(self)
  return UserPresenter.show(self.params.id)
end)

app:post("/users", function(self)
  return UserPresenter.create(self.params)
end)

app:put("/users/:id", function(self)
  return UserPresenter.update(self.params.id, self.params)
end)

app:delete("/users/:id", function(self)
  return UserPresenter.destroy(self.params.id)
end)

-- OpenAPI specification
app:get("/openapi.json", function()
  return OpenapiPresenter.show()
end)

app:get("/docs", function(self)
  return SwaggerPresenter.show(self)
end)

return app

