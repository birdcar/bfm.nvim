local M = {}

function M.check()
  vim.health.start("bfm.nvim")

  -- Check nvim-treesitter
  local ok, _ = pcall(require, "nvim-treesitter")
  if ok then
    vim.health.ok("nvim-treesitter found")
  else
    vim.health.error("nvim-treesitter not found", { "Install nvim-treesitter" })
  end

  -- Check tree-sitter-bfm parser
  local has_parser = pcall(vim.treesitter.language.inspect, "bfm")
  if has_parser then
    vim.health.ok("tree-sitter-bfm parser installed")
  else
    vim.health.warn("tree-sitter-bfm parser not installed", {
      "Run :TSInstall bfm bfm_inline",
      "Or add parser config to nvim-treesitter",
    })
  end

  -- Check nvim-cmp
  local has_cmp, _ = pcall(require, "cmp")
  if has_cmp then
    vim.health.ok("nvim-cmp found")
  else
    vim.health.warn("nvim-cmp not found", { "Completion features disabled" })
  end

  -- Check LuaSnip
  local has_luasnip, _ = pcall(require, "luasnip")
  if has_luasnip then
    vim.health.ok("LuaSnip found")
  else
    vim.health.info("LuaSnip not found — using native vim.snippet format")
  end
end

return M
