local JsonView = {}

-- Success response
function JsonView.success(data, status)
  local response = {
    success = true
  }
  
  -- Merge data into response
  for k, v in pairs(data) do
    response[k] = v
  end
  
  return {
    status = status or 200,
    json = response
  }
end

-- Error response
function JsonView.error(message, status)
  return {
    status = status or 400,
    json = {
      success = false,
      error = message
    }
  }
end

return JsonView
