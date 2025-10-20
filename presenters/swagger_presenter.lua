local SwaggerPresenter = {}

local function html_document()
  return [[<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Legal API Docs</title>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.11.0/swagger-ui.css" />
    <style>
      body { margin: 0; background: #fafafa; }
      #swagger-ui { height: 100vh; }
    </style>
  </head>
  <body>
    <div id="swagger-ui"></div>
    <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.11.0/swagger-ui-bundle.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.11.0/swagger-ui-standalone-preset.js"></script>
    <script>
      window.addEventListener("load", function () {
        SwaggerUIBundle({
          url: "/openapi.json",
          dom_id: "#swagger-ui",
          presets: [SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset],
          layout: "StandaloneLayout"
        });
      });
    </script>
  </body>
</html>]]
end

function SwaggerPresenter.show(context)
  local response = {
    status = 200,
    layout = false
  }

  local html = html_document()

  if context and context.res and context.write then
    context.res.headers["Content-Type"] = "text/html; charset=utf-8"
    context:write(html)
    return response
  end

  response.render = false
  response.content_type = "text/html; charset=utf-8"
  response.content = html

  return response
end

return SwaggerPresenter
