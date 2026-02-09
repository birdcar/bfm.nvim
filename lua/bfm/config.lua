local M = {}

local defaults = {
  completion = {
    enabled = true,
    trigger_characters = { "@", "/" },
  },
  mentions = {
    git = true,
    file = true,
    cache_ttl = 300,
  },
  snippets = {
    enabled = true,
  },
  highlights = {
    enabled = true,
  },
  cycling = {
    order = { " ", "x", ">", "<", "-", "o", "!" },
  },
  folding = {
    enabled = true,
  },
  conceal = {
    enabled = true,
    icons = {},
  },
  keymaps = {
    cycle_forward = "<leader>tt",
    cycle_backward = "<leader>tT",
    insert_date = "<leader>td",
  },
}

local current = {}

function M.setup(opts)
  current = vim.tbl_deep_extend("force", defaults, opts or {})
end

function M.get()
  return current
end

return M
