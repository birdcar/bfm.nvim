local M = {}
local providers = {}

function M.register(provider)
  table.insert(providers, provider)
end

function M.get_providers()
  return providers
end

return M
