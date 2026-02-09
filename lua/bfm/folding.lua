local M = {}

function M.setup(bufnr)
  local config = require("bfm.config").get()
  if not config.folding.enabled then return end

  -- Only set foldmethod if not already configured by user
  if vim.wo.foldmethod == "manual" then
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldtext = "v:lua.require('bfm.folding').foldtext()"
    vim.wo.foldenable = true
    vim.wo.foldlevel = 99
  end
end

function M.foldtext()
  local bufnr = vim.api.nvim_get_current_buf()
  local foldstart = vim.v.foldstart
  local foldend = vim.v.foldend
  local line = vim.api.nvim_buf_get_lines(bufnr, foldstart - 1, foldstart, false)[1]
  local line_count = foldend - foldstart - 1

  local name = line:match("@(%a+)")
  local params_str = line:match("@%a+%s+(.+)$") or ""

  local label = "@" .. (name or "directive")
  if params_str ~= "" then
    label = label .. " " .. params_str
  end
  label = label .. " [" .. line_count .. " lines]"

  return label
end

return M
