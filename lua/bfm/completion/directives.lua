local M = {}

-- LSP CompletionItemKind
local Kind = { Keyword = 14, Snippet = 15, Property = 10, EnumMember = 20 }

local directives = {
  callout = {
    params = {
      type = { "info", "warning", "danger", "success", "note" },
      title = true,
    },
    snippet = '@callout type=${1|info,warning,danger,success,note|} title="${2:Title}"\n${0}\n@endcallout',
  },
  embed = {
    params = {},
    snippet = "@embed ${1:https://}\n${2:Caption text}\n@endembed",
  },
}

function M.complete_names()
  local items = {}
  for name, def in pairs(directives) do
    table.insert(items, {
      label = name,
      kind = Kind.Keyword,
      detail = "BFM directive",
      insertText = def.snippet,
      insertTextFormat = 2,
    })
  end
  return { items = items, is_incomplete_forward = false, is_incomplete_backward = false }
end

function M.complete_params(ctx)
  local items = {}
  local def = directives[ctx.directive_name]
  if not def then
    return { items = items, is_incomplete_forward = false, is_incomplete_backward = false }
  end

  for key, values in pairs(def.params) do
    if type(values) == "table" then
      for _, val in ipairs(values) do
        table.insert(items, {
          label = key .. "=" .. val,
          kind = Kind.EnumMember,
          detail = "Parameter",
          insertText = key .. "=" .. val,
        })
      end
    else
      table.insert(items, {
        label = key .. "=",
        kind = Kind.Property,
        detail = "Parameter (free-form)",
        insertText = key .. '="$1"',
        insertTextFormat = 2,
      })
    end
  end
  return { items = items, is_incomplete_forward = false, is_incomplete_backward = false }
end

return M
