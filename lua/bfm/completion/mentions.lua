local M = {}

-- LSP CompletionItemKind
local Kind = { Reference = 18 }

function M.complete(callback)
  local mentions = require("bfm.mentions")
  local items = {}
  local providers = mentions.get_providers()
  local pending = #providers
  local seen = {}

  if pending == 0 then
    callback({ items = {}, is_incomplete_forward = false, is_incomplete_backward = false })
    return
  end

  for _, provider in ipairs(providers) do
    provider.complete(function(results)
      for _, result in ipairs(results) do
        if not seen[result.label] then
          seen[result.label] = true
          table.insert(items, {
            label = "@" .. result.label,
            kind = Kind.Reference,
            detail = result.detail or "Mention",
            insertText = result.label,
            filterText = "@" .. result.label,
          })
        end
      end

      pending = pending - 1
      if pending == 0 then
        callback({ items = items, is_incomplete_forward = false, is_incomplete_backward = false })
      end
    end)
  end
end

return M
