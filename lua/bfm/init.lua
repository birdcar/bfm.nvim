local M = {}

function M.setup(opts)
  local config = require("bfm.config")
  config.setup(opts)

  if config.get().highlights.enabled then
    require("bfm.highlights").setup()
  end

  local mentions = require("bfm.mentions")
  if config.get().mentions.git then
    mentions.register(require("bfm.mentions.git"))
  end
  if config.get().mentions.file then
    mentions.register(require("bfm.mentions.file"))
  end

  if config.get().snippets.enabled then
    local ok, _ = pcall(require, "luasnip")
    if ok then
      require("bfm.snippets").setup()
    end
  end

  M._setup_autocmds()
end

function M._setup_buffer(bufnr)
  require("bfm.folding").setup(bufnr)
  require("bfm.conceal").setup(bufnr)
  require("bfm.keymaps").setup(bufnr)
end

function M._setup_autocmds()
  local group = vim.api.nvim_create_augroup("bfm", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "markdown",
    callback = function(args)
      M._setup_buffer(args.buf)
    end,
    desc = "Set up BFM features for markdown buffers",
  })
end

function M.register_mention_source(fn)
  require("bfm.mentions").register({ complete = fn })
end

return M
