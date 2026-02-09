local M = {}

function M.setup()
  local links = {
    ["@bfm.task.open"] = "@comment",
    ["@bfm.task.done"] = "@string",
    ["@bfm.task.scheduled"] = "@type",
    ["@bfm.task.migrated"] = "@constant",
    ["@bfm.task.irrelevant"] = "@comment.note",
    ["@bfm.task.event"] = "@function",
    ["@bfm.task.priority"] = "@exception",
    ["@bfm.mention"] = "@tag",
  }

  for group, link in pairs(links) do
    vim.api.nvim_set_hl(0, group, { link = link, default = true })
  end
end

return M
