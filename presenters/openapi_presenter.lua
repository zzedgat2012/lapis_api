local Spec = require("openapi.spec")

local OpenapiPresenter = {}

function OpenapiPresenter.show()
  return {
    status = 200,
    json = Spec
  }
end

return OpenapiPresenter
