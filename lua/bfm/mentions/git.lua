local M = {}
local cache = {}
local cache_time = 0

function M.complete(callback)
  local config = require("bfm.config").get()
  local ttl = config.mentions.cache_ttl

  if os.time() - cache_time < ttl and #cache > 0 then
    callback(cache)
    return
  end

  vim.system(
    { "git", "log", "--format=%aN", "--all" },
    { text = true, cwd = vim.fn.getcwd() },
    function(result)
      if result.code ~= 0 then
        callback({})
        return
      end

      local seen = {}
      local items = {}
      for name in result.stdout:gmatch("[^\n]+") do
        local id = name:lower():gsub("%s+", ".")
        if not seen[id] then
          seen[id] = true
          table.insert(items, {
            label = id,
            detail = name .. " (git)",
          })
        end
      end

      cache = items
      cache_time = os.time()
      vim.schedule(function() callback(items) end)
    end
  )
end

return M
