#!/usr/bin/env lua

local io = io
local os = os
local table = table
local string = string

local args = {...}

local function print_usage()
  io.stderr:write([[Usage: lua scripts/model_generator.lua --name <ModelName> [--scaffold crud]

Options:
  -n, --name <ModelName>       Model name in CamelCase or snake_case
  -s, --scaffold <type>        Optional scaffold type (only "crud" supported)
]])
end

local function to_snake_case(value)
  local result = value:gsub("%s+", "_")
  result = result:gsub("%-", "_")
  result = result:gsub("::", "/")
  result = result:gsub("([A-Za-z%d])([A-Z])", "%1_%2")
  result = result:gsub("__+", "_")
  result = result:gsub("/", "_")
  result = result:lower()
  return result
end

local function to_pascal_case(value)
  local working = value:gsub("[_%-]", " ")
  working = working:gsub("(%a)([%w]*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
  working = working:gsub("%s+", "")
  return working
end

local function pluralize(value)
  if value:match("s$") then
    return value .. "es"
  elseif value:match("y$") and not value:match("[aeiou]y$") then
    return value:sub(1, -2) .. "ies"
  else
    return value .. "s"
  end
end

local function ensure_directory(path)
  local command = string.format('mkdir -p "%s"', path)
  local ok = os.execute(command)
  if not ok then
    error("Failed to create directory: " .. path)
  end
end

local function file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

local function write_file(path, contents)
  local file, err = io.open(path, "w")
  if not file then
    error("Failed to open file for writing: " .. path .. " (" .. tostring(err) .. ")")
  end
  file:write(contents)
  file:close()
end

local function update_app_with_routes(pascal_name, snake_name, plural_table)
  local app_path = "app.lua"
  local file = io.open(app_path, "r")
  if not file then
    io.stderr:write("Warning: could not open app.lua to register routes.\n")
    return
  end

  local app_content = file:read("*a")
  file:close()

  local presenter_require = string.format('local %sPresenter = require("presenters.%s_presenter")', pascal_name, snake_name)
  if not app_content:find(presenter_require, 1, true) then
    local replaced
    app_content, replaced = app_content:gsub("(%-%- Home route)", presenter_require .. "\n%1", 1)
    if replaced == 0 then
      app_content = presenter_require .. "\n" .. app_content
    end
  end

  local routes_block = string.format([[-- %s routes
app:get("/%s", function(self)
  return %sPresenter.index()
end)

app:get("/%s/:id", function(self)
  return %sPresenter.show(self.params.id)
end)

app:post("/%s", function(self)
  return %sPresenter.create(self.params)
end)

app:put("/%s/:id", function(self)
  return %sPresenter.update(self.params.id, self.params)
end)

app:delete("/%s/:id", function(self)
  return %sPresenter.destroy(self.params.id)
end)

]],
    pascal_name,
    plural_table,
    pascal_name,
    plural_table,
    pascal_name,
    plural_table,
    pascal_name,
    plural_table,
    pascal_name,
    plural_table,
    pascal_name)

  if not app_content:find(string.format("-- %s routes", pascal_name), 1, true) then
    local replaced
    app_content, replaced = app_content:gsub("(%-%- OpenAPI specification)", routes_block .. "%1", 1)
    if replaced == 0 then
      app_content, replaced = app_content:gsub("(return app)", routes_block .. "%1", 1)
      if replaced == 0 then
        app_content = app_content .. "\n" .. routes_block
      end
    end
  end

  write_file(app_path, app_content)
end

local function replace_placeholders(template, replacements)
  local result = template
  for placeholder, value in pairs(replacements) do
    local pattern = placeholder:gsub("(%W)", "%%%1")
    result = result:gsub(pattern, value)
  end
  return result
end

local function update_openapi_spec(pascal_name, snake_name, plural_table)
  local spec_path = "openapi/spec.lua"
  local file = io.open(spec_path, "r")
  if not file then
    io.stderr:write("Warning: could not open openapi/spec.lua to register resource.\n")
    return
  end

  local content = file:read("*a")
  file:close()

  if content:find(string.format('spec.paths["/%s"]', plural_table), 1, true) then
    return
  end

  local plural_pascal = to_pascal_case(plural_table)

  local template = [=[

spec.tags[#spec.tags + 1] = { name = "__TAG__", description = "__SINGULAR__ endpoints" }

spec.components.schemas.__SINGULAR__ = {
  type = "object",
  required = { "id", "name", "created_at", "updated_at" },
  properties = {
    id = { type = "integer", format = "int64", example = 1 },
    name = { type = "string", example = "__SINGULAR__ name" },
    created_at = { type = "string", format = "date-time", example = "2025-01-01T12:34:56Z" },
    updated_at = { type = "string", format = "date-time", example = "2025-01-01T12:34:56Z" }
  }
}

spec.components.schemas.__SINGULAR__Input = {
  type = "object",
  properties = {
    name = { type = "string", example = "__SINGULAR__ name" }
  },
  required = { "name" }
}

spec.components.schemas.__SINGULAR__UpdateInput = {
  type = "object",
  properties = {
    name = { type = "string" }
  }
}

spec.components.schemas.__SINGULAR__ListResponse = {
  type = "object",
  required = { "success", "count", "__PLURAL_LOWER__" },
  properties = {
    success = { type = "boolean", example = true },
    count = { type = "integer", format = "int32", example = 1 },
    __PLURAL_LOWER__ = {
      type = "array",
      items = { ["$ref"] = "#/components/schemas/__SINGULAR__" }
    }
  }
}

spec.components.schemas.__SINGULAR__ItemResponse = {
  allOf = {
    { ["$ref"] = "#/components/schemas/SuccessResponse" },
    {
      type = "object",
      required = { "__SINGULAR_LOWER__" },
      properties = {
        __SINGULAR_LOWER__ = { ["$ref"] = "#/components/schemas/__SINGULAR__" }
      }
    }
  }
}

spec.components.schemas.__SINGULAR__DeletedResponse = {
  allOf = {
    { ["$ref"] = "#/components/schemas/SuccessResponse" },
    {
      type = "object",
      properties = {
        message = { type = "string", example = "__SINGULAR__ deleted successfully" }
      }
    }
  }
}

spec.components.parameters.__SINGULAR__Id = {
  name = "id",
  ["in"] = "path",
  required = true,
  schema = { type = "integer", format = "int64" },
  description = "Unique identifier of the __SINGULAR_LOWER__"
}

spec.paths["/__PLURAL_LOWER__"] = {
  get = {
    tags = { "__TAG__" },
    summary = "List __PLURAL__",
    description = "Returns a pageless list of __PLURAL__",
    responses = {
      ["200"] = {
        description = "Successful response",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/__SINGULAR__ListResponse" }
          }
        }
      }
    }
  },
  post = {
    tags = { "__TAG__" },
    summary = "Create __SINGULAR__",
    description = "Creates a new __SINGULAR_LOWER__",
    requestBody = {
      required = true,
      content = {
        ["application/json"] = {
          schema = { ["$ref"] = "#/components/schemas/__SINGULAR__Input" }
        },
        ["application/x-www-form-urlencoded"] = {
          schema = { ["$ref"] = "#/components/schemas/__SINGULAR__Input" }
        }
      }
    },
    responses = {
      ["201"] = {
        description = "__SINGULAR__ created",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/__SINGULAR__ItemResponse" }
          }
        }
      },
      ["400"] = {
        description = "Invalid input",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/ErrorResponse" }
          }
        }
      }
    }
  }
}

spec.paths["/__PLURAL_LOWER__/{id}"] = {
  get = {
    tags = { "__TAG__" },
    summary = "Get __SINGULAR__",
    description = "Returns a __SINGULAR_LOWER__ by ID",
    parameters = {
      { ["$ref"] = "#/components/parameters/__SINGULAR__Id" }
    },
    responses = {
      ["200"] = {
        description = "__SINGULAR__ found",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/__SINGULAR__ItemResponse" }
          }
        }
      },
      ["404"] = {
        description = "__SINGULAR__ not found",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/ErrorResponse" }
          }
        }
      }
    }
  },
  put = {
    tags = { "__TAG__" },
    summary = "Update __SINGULAR__",
    description = "Updates an existing __SINGULAR_LOWER__",
    parameters = {
      { ["$ref"] = "#/components/parameters/__SINGULAR__Id" }
    },
    requestBody = {
      required = true,
      content = {
        ["application/json"] = {
          schema = { ["$ref"] = "#/components/schemas/__SINGULAR__UpdateInput" }
        },
        ["application/x-www-form-urlencoded"] = {
          schema = { ["$ref"] = "#/components/schemas/__SINGULAR__UpdateInput" }
        }
      }
    },
    responses = {
      ["200"] = {
        description = "__SINGULAR__ updated",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/__SINGULAR__ItemResponse" }
          }
        }
      },
      ["404"] = {
        description = "__SINGULAR__ not found",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/ErrorResponse" }
          }
        }
      }
    }
  },
  delete = {
    tags = { "__TAG__" },
    summary = "Delete __SINGULAR__",
    description = "Deletes a __SINGULAR_LOWER__ by ID",
    parameters = {
      { ["$ref"] = "#/components/parameters/__SINGULAR__Id" }
    },
    responses = {
      ["200"] = {
        description = "__SINGULAR__ deleted",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/__SINGULAR__DeletedResponse" }
          }
        }
      },
      ["404"] = {
        description = "__SINGULAR__ not found",
        content = {
          ["application/json"] = {
            schema = { ["$ref"] = "#/components/schemas/ErrorResponse" }
          }
        }
      }
    }
  }
}
]=]

  local replacements = {
    __TAG__ = plural_pascal,
    __SINGULAR__ = pascal_name,
    __SINGULAR_LOWER__ = snake_name,
    __PLURAL_LOWER__ = plural_table,
    __PLURAL__ = plural_pascal
  }

  local block = replace_placeholders(template, replacements)

  local replaced
  content, replaced = content:gsub("return spec", block .. "\nreturn spec", 1)
  if replaced == 0 then
    io.stderr:write("Warning: could not inject OpenAPI block for resource.\n")
    return
  end

  write_file(spec_path, content)
end

local options = {
  name = nil,
  scaffold = nil
}

local i = 1
while i <= #args do
  local argval = args[i]
  if argval == "-n" or argval == "--name" then
    options.name = args[i + 1]
    i = i + 1
  elseif argval == "-s" or argval == "--scaffold" then
    options.scaffold = args[i + 1]
    i = i + 1
  elseif argval:match("^--name=") then
    options.name = argval:match("^--name=(.*)")
  elseif argval:match("^--scaffold=") then
    options.scaffold = argval:match("^--scaffold=(.*)")
  elseif argval:match("^NAME=") then
    options.name = argval:match("^NAME=(.*)")
  elseif argval:match("^SCAFFOLD=") then
    options.scaffold = argval:match("^SCAFFOLD=(.*)")
  end
  i = i + 1
end

if not options.name or options.name == "" then
  print_usage()
  os.exit(1)
end

local raw_name = options.name
local snake_name = to_snake_case(raw_name)
local pascal_name = to_pascal_case(raw_name)
local plural_table = pluralize(snake_name)
local timestamp = os.date("%Y%m%d_%H%M%S")

local model_path = string.format("models/%s.lua", snake_name)
local migration_filename = string.format("%s_create_%s.lua", timestamp, snake_name)
local migration_path = string.format("migrations/%s", migration_filename)
local migration_module = string.format("%s_create_%s", timestamp, snake_name)

if file_exists(model_path) then
  io.stderr:write("Model already exists: " .. model_path .. "\n")
  os.exit(1)
end

if file_exists(migration_path) then
  io.stderr:write("Migration already exists: " .. migration_path .. "\n")
  os.exit(1)
end

ensure_directory("models")
ensure_directory("migrations")
ensure_directory("presenters")
ensure_directory("views")
ensure_directory("tests")

local scaffold_requested = false
if options.scaffold and options.scaffold ~= "" then
  scaffold_requested = string.lower(options.scaffold) == "crud"
end

local model_template

if scaffold_requested then
  model_template = string.format([=[local Database = require("utils.database")

local %s = {}
local TABLE_NAME = "%s"

local function first_or_nil(rows)
  if type(rows) ~= "table" then
    return nil
  end
  return rows[1]
end

-- Fetch all records ordered by id
function %s.all()
  local rows = Database.select(("SELECT * FROM %%s ORDER BY id"):format(TABLE_NAME))
  return rows or {}
end

-- Find a record by primary key
function %s.find(id)
  local rows = Database.select(("SELECT * FROM %%s WHERE id = ?"):format(TABLE_NAME), id)
  return first_or_nil(rows)
end

-- Create a new record and return the persisted row
function %s.create(attrs)
  -- TODO: filter and validate attrs before inserting
  local new_id, err = Database.insert(TABLE_NAME, attrs or {})
  if not new_id then
    return nil, err
  end
  return %s.find(new_id)
end

-- Update an existing record by id
function %s.update(id, attrs)
  -- TODO: filter attrs to include only allowed columns
  local ok, err = Database.update(TABLE_NAME, attrs or {}, { id = id })
  if not ok then
    return nil, err
  end
  return %s.find(id)
end

-- Delete a record by id
function %s.delete(id)
  local ok, err = Database.delete(TABLE_NAME, { id = id })
  if not ok then
    return nil, err
  end
  return true
end

return %s
]=], pascal_name, plural_table, pascal_name, pascal_name, pascal_name, pascal_name, pascal_name, pascal_name, pascal_name, pascal_name, pascal_name)
else
  model_template = string.format([=[local Database = require("utils.database")

local %s = {}
local TABLE_NAME = "%s"

-- Fetch all records
function %s.all()
  -- TODO: tailor the query for %s
  return Database.select(("SELECT * FROM %%s ORDER BY id"):format(TABLE_NAME))
end

-- Insert a new record
function %s.create(attrs)
  -- TODO: tailor fields for %s
  Database.insert(TABLE_NAME, attrs)
end

return %s
]=], pascal_name, plural_table, pascal_name, pascal_name, pascal_name, pascal_name, pascal_name)
end

write_file(model_path, model_template)

local migration_template = string.format([=[local db = require("lapis.db")

local migration = {}

migration[1] = function()
  -- TODO: adjust columns and indexes for %s
  db.query([[CREATE TABLE IF NOT EXISTS %s (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );]])

  db.query([[CREATE TRIGGER IF NOT EXISTS trigger_%s_updated_at
    AFTER UPDATE ON %s
    FOR EACH ROW BEGIN
      UPDATE %s SET updated_at = CURRENT_TIMESTAMP WHERE id = OLD.id;
    END;]])
end

function migration.down()
  db.query([[DROP TRIGGER IF EXISTS trigger_%s_updated_at;]])
  db.query([[DROP TABLE IF EXISTS %s;]])
end

return setmetatable(migration, {
  __call = function(_, ...)
    local fn = migration[1]
    if type(fn) ~= "function" then
      error("Migration does not define an up function")
    end
    return fn(...)
  end
})
]=], pascal_name, plural_table, plural_table, plural_table, plural_table, plural_table, plural_table)

write_file(migration_path, migration_template)

local init_path = "migrations/init.lua"
local init_file = io.open(init_path, "r")
if not init_file then
  io.stderr:write("Could not open migrations/init.lua. Did you run the project bootstrap?\n")
  os.exit(1)
end
local init_content = init_file:read("*a")
init_file:close()

local max_index = 0
for index in init_content:gmatch("migrations%[(%d+)%]") do
  local n = tonumber(index)
  if n and n > max_index then
    max_index = n
  end
end

local new_index = max_index + 1
local require_line = string.format('migrations[%d] = require("migrations.%s")', new_index, migration_module)

if init_content:find(require_line, 1, true) then
  io.stderr:write("Migration list already contains entry for " .. migration_module .. "\n")
else
  init_content = init_content:gsub("return migrations", require_line .. "\n\nreturn migrations")
  write_file(init_path, init_content)
end

os.execute(string.format('chmod 664 "%s" "%s"', model_path, migration_path))

if scaffold_requested then
  local presenter_path = string.format("presenters/%s_presenter.lua", snake_name)
  local view_path = string.format("views/%s_view.lua", snake_name)
  local test_path = string.format("tests/%s_spec.lua", snake_name)

  if file_exists(presenter_path) or file_exists(view_path) or file_exists(test_path) then
    io.stderr:write("Scaffold files already exist; skipping CRUD scaffold creation.\n")
  else
    local presenter_template = string.format([=[local %s = require("models.%s")
local View = require("views.json_view")

local %sPresenter = {}

function %sPresenter.index()
  local records = %s.all()
  return View.success({ count = #records, %s = records })
end

function %sPresenter.show(id)
  local record_id = tonumber(id)
  if not record_id then
    return View.error("Invalid identifier", 400)
  end

  local record = %s.find(record_id)

  if not record then
    return View.error("%s not found", 404)
  end

  return View.success({ %s = record })
end

function %sPresenter.create(params)
  -- TODO: sanitize and validate attributes for %s
  local record = %s.create(params)
  if not record then
    return View.error("Failed to create %s", 422)
  end

  return View.success({ %s = record }, 201)
end

function %sPresenter.update(id, params)
  local record_id = tonumber(id)
  if not record_id then
    return View.error("Invalid identifier", 400)
  end

  local existing = %s.find(record_id)

  if not existing then
    return View.error("%s not found", 404)
  end

  -- TODO: sanitize and validate attributes for %s
  local updated = %s.update(record_id, params)
  if not updated then
    return View.error("Failed to update %s", 422)
  end

  return View.success({ %s = updated })
end

function %sPresenter.destroy(id)
  local record_id = tonumber(id)
  if not record_id then
    return View.error("Invalid identifier", 400)
  end

  local existing = %s.find(record_id)

  if not existing then
    return View.error("%s not found", 404)
  end

  local ok = %s.delete(record_id)
  if not ok then
    return View.error("Failed to delete %s", 422)
  end

  return View.success({ message = "%s deleted successfully" })
end

return %sPresenter
]=],
  pascal_name,          -- model module (Pascal)
  snake_name,           -- model path (snake)
  pascal_name,          -- presenter table name
  pascal_name,          -- index function name
  pascal_name,          -- model access in index
  plural_table,         -- response collection key
  pascal_name,          -- show function name
  pascal_name,          -- model access in show
  pascal_name,          -- not found message (Pascal)
  snake_name,           -- singular response key
  pascal_name,          -- create function name
  pascal_name,          -- TODO reference for create
  pascal_name,          -- model create call
  pascal_name,          -- create error message
  snake_name,           -- create success key
  pascal_name,          -- update function name
  pascal_name,          -- find existing record
  pascal_name,          -- not found message
  pascal_name,          -- TODO reference for update
  pascal_name,          -- model update call
  pascal_name,          -- update error message
  snake_name,           -- update success key
  pascal_name,          -- destroy function name
  pascal_name,          -- find existing record
  pascal_name,          -- not found message
  pascal_name,          -- model delete call
  pascal_name,          -- delete error message
  pascal_name,          -- delete success message
  pascal_name)          -- return presenter

    local view_template = string.format([=[local JsonView = require("views.json_view")

local %sView = {}

function %sView.success(payload, status)
  return JsonView.success(payload, status)
end

function %sView.error(message, status)
  return JsonView.error(message, status)
end

return %sView
]=], pascal_name, pascal_name, pascal_name, pascal_name)

    local test_template = string.format([=[---@diagnostic disable: undefined-global

local assert = require("luassert")

describe("%s presenter", function()
  it("marks CRUD tests for %s as pending", function()
    pending("Add CRUD tests for %s presenter")
  end)
end)
]=], pascal_name, pascal_name, pascal_name)

    write_file(presenter_path, presenter_template)
    write_file(view_path, view_template)
    write_file(test_path, test_template)

    os.execute(string.format('chmod 664 "%s" "%s" "%s"', presenter_path, view_path, test_path))
  end

  update_app_with_routes(pascal_name, snake_name, plural_table)
  update_openapi_spec(pascal_name, snake_name, plural_table)
end

io.stdout:write(string.format("Generated model '%s' with migration '%s'\n", pascal_name, migration_filename))
if scaffold_requested then
  io.stdout:write("CRUD scaffold stubs created: presenter, view, test, and app.lua routes registered.\n")
end
