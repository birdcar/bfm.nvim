local M = {}

-- LSP CompletionItemKind
local Kind = { Property = 10, Value = 12 }

local modifier_keys = {
  { key = "due", desc = "Hard deadline (ISO 8601 date)", has_value = true },
  { key = "around", desc = "Soft/approximate target date", has_value = true },
  { key = "after", desc = "Don't surface until this date", has_value = true },
  { key = "every", desc = "Repeating schedule", has_value = true },
  { key = "cron", desc = "Cron expression for recurrence", has_value = true },
  { key = "hard", desc = "Immovable deadline (flag)", has_value = false },
  { key = "wait", desc = "Blocked / waiting on external input (flag)", has_value = false },
}

local recurrence_values = {
  "daily", "weekly", "2-weeks", "monthly", "quarterly", "yearly",
  "weekdays", "weekends",
  "mon", "tue", "wed", "thu", "fri", "sat", "sun",
  "1st", "15th",
}

function M.complete(ctx)
  local items = {}

  if ctx.modifier_key then
    items = M._complete_values(ctx.modifier_key)
  else
    for _, mod in ipairs(modifier_keys) do
      local insert = mod.has_value and (mod.key .. ":") or mod.key
      table.insert(items, {
        label = "//" .. mod.key,
        kind = Kind.Property,
        detail = mod.desc,
        insertText = insert,
        filterText = "//" .. mod.key,
      })
    end
  end

  return { items = items, is_incomplete_forward = false, is_incomplete_backward = false }
end

function M._complete_values(key)
  local items = {}

  if key == "every" then
    for _, val in ipairs(recurrence_values) do
      table.insert(items, {
        label = val,
        kind = Kind.Value,
        detail = "Recurrence: " .. val,
      })
    end
  elseif key == "due" or key == "around" or key == "after" then
    local today = os.date("%Y-%m-%d")
    table.insert(items, {
      label = today,
      kind = Kind.Value,
      detail = "Today",
    })
    table.insert(items, {
      label = os.date("%Y-%m", os.time() + 30 * 86400),
      kind = Kind.Value,
      detail = "Next month (partial)",
    })
  end

  return items
end

return M
