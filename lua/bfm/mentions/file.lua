local M = {}

function M.complete(callback)
  local paths = {
    vim.fn.getcwd() .. "/.bfm-mentions",
    vim.fn.expand("~/.config/bfm/mentions"),
  }

  local items = {}
  for _, path in ipairs(paths) do
    local f = io.open(path, "r")
    if f then
      for line in f:lines() do
        local id = vim.trim(line)
        if id ~= "" and not id:match("^#") then
          table.insert(items, {
            label = id,
            detail = "(.bfm-mentions)",
          })
        end
      end
      f:close()
    end
  end

  callback(items)
end

return M
