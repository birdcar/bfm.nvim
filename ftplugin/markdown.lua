-- BFM-specific buffer settings for markdown files
-- This runs automatically when a markdown file is opened

-- Add snippet path for native vim.snippet users
local snippet_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h") .. "/snippets"
if not vim.tbl_contains(vim.opt.runtimepath:get(), snippet_path) then
  vim.opt.runtimepath:append(snippet_path)
end
