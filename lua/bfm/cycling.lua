local M = {}

local default_cycle = { " ", "x", ">", "<", "-", "o", "!" }

function M.cycle_forward(opts)
  opts = opts or {}
  local config = require("bfm.config")
  local cycle = config.get().cycling.order or default_cycle
  local start_line, end_line = M._get_range(opts.visual)

  for lnum = start_line, end_line do
    M._cycle_line(lnum, cycle, 1)
  end
end

function M.cycle_backward(opts)
  opts = opts or {}
  local config = require("bfm.config")
  local cycle = config.get().cycling.order or default_cycle
  local start_line, end_line = M._get_range(opts.visual)

  for lnum = start_line, end_line do
    M._cycle_line(lnum, cycle, -1)
  end
end

function M._get_range(visual)
  if visual then
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    return start_line, end_line
  else
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    return lnum, lnum
  end
end

function M._cycle_line(lnum, cycle, direction)
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  if not line then return end

  -- Match task marker pattern: optional whitespace + list marker + [state]
  local prefix, state, suffix = line:match("^(%s*[%-*+%d%.]+%s*%[)([%sxX><%-o!])(%].*)$")
  if not prefix then return end

  -- Normalize: X -> x
  state = state:lower()

  -- Find current position in cycle
  local idx = nil
  for i, s in ipairs(cycle) do
    if s == state then
      idx = i
      break
    end
  end

  if not idx then
    idx = 0
  end

  -- Calculate next state
  local next_idx = ((idx - 1 + direction) % #cycle) + 1
  local next_state = cycle[next_idx]

  local new_line = prefix .. next_state .. suffix
  vim.api.nvim_buf_set_lines(bufnr, lnum - 1, lnum, false, { new_line })
end

return M
