#!/usr/bin/env lua

local args = {...}

local function print_usage()
  io.stderr:write([[Usage: luajit scripts/migration_manager.lua <command> [options]

Commands:
  rollback [--steps N]   Roll back the last N applied migrations (default: 1)
  list                   List applied migration identifiers

Options:
  -h, --help             Show this help message
  -s, --steps <N>        Number of migrations to roll back (with rollback command)
]])
end

if #args == 0 then
  print_usage()
  os.exit(1)
end

local command = args[1]
if command == "-h" or command == "--help" then
  print_usage()
  os.exit(0)
end

table.remove(args, 1)

local Environment = require("lapis.environment")
local env = os.getenv("LAPIS_ENV") or "development"
Environment.push(env)

local db = require("lapis.db")
local migrations = require("migrations")

local function list_migrations()
  local rows, err = db.query("SELECT name FROM lapis_migrations ORDER BY name")
  if not rows then
    io.stderr:write(string.format("Failed to query lapis_migrations: %s\n", err or "unknown error"))
    return false
  end

  if #rows == 0 then
    io.stdout:write("No migrations have been applied.\n")
    return true
  end

  for _, row in ipairs(rows) do
    if row.name then
      io.stdout:write(string.format("%s\n", row.name))
    end
  end
  return true
end

local function parse_steps(arguments)
  local steps = 1
  local i = 1
  while i <= #arguments do
    local value = arguments[i]
    if value == "-s" or value == "--steps" then
      local next_value = arguments[i + 1]
      if not next_value then
        return nil, "Missing value for --steps option"
      end
      local parsed = tonumber(next_value)
      if not parsed then
        return nil, "Steps value must be numeric"
      end
      steps = parsed
      i = i + 1
    elseif value:match("^%-%-steps=") then
      local extracted = value:match("^%-%-steps=(.+)")
      local parsed_inline = tonumber(extracted)
      if not parsed_inline then
        return nil, "Steps value must be numeric"
      end
      steps = parsed_inline
    else
      io.stderr:write(string.format("Unknown option '%s'\n", value))
      return nil, "Unknown option"
    end
    i = i + 1
  end

  if not steps or steps < 1 then
    return nil, "Steps must be a positive integer"
  end

  return steps
end

local function rollback(arguments)
  local steps, err = parse_steps(arguments)
  if not steps then
    if err then
      io.stderr:write(err .. "\n")
    end
    return false
  end

  local applied, query_err = db.query("SELECT name FROM lapis_migrations ORDER BY name")
  if not applied then
    io.stderr:write(string.format("Failed to fetch applied migrations: %s\n", query_err or "unknown error"))
    return false
  end

  if #applied == 0 then
    io.stdout:write("No migrations to roll back.\n")
    return true
  end

  local target_index = #applied - steps + 1
  if target_index < 1 then
    target_index = 1
  end

  for i = #applied, target_index, -1 do
    local entry = applied[i]
    local name = entry.name
    local numeric_name = tonumber(name)
    if not numeric_name then
      io.stderr:write(string.format("Migration '%s' cannot be rolled back automatically (non-numeric identifier).\n", tostring(name)))
      return false
    end

    local migration = migrations[numeric_name]
    if not migration then
      io.stderr:write(string.format("Migration %d not found in migrations/init.lua.\n", numeric_name))
      return false
    end

    local down_fn
    if type(migration) == "table" then
      down_fn = migration.down
    end

    if type(down_fn) ~= "function" then
      io.stderr:write(string.format("Migration %d does not expose a down() function. Aborting at this migration.\n", numeric_name))
      return false
    end

    db.query("BEGIN")
    local ok, down_err = pcall(down_fn)
    if not ok then
      db.query("ROLLBACK")
      io.stderr:write(string.format("Error rolling back migration %d: %s\n", numeric_name, down_err))
      return false
    end

    db.query("DELETE FROM lapis_migrations WHERE name = ?", name)
    db.query("COMMIT")

    io.stdout:write(string.format("Rolled back migration %d\n", numeric_name))
  end

  return true
end

local ok
if command == "rollback" then
  ok = rollback(args)
elseif command == "list" then
  ok = list_migrations()
else
  print_usage()
  ok = false
end

Environment.pop()

if not ok then
  os.exit(1)
end
