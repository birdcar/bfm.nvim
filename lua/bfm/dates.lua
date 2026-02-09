local M = {}

function M.insert_date(opts)
  opts = opts or {}
  local offset_days = opts.offset or 0
  local date = os.date("%Y-%m-%d", os.time() + offset_days * 86400)

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]

  -- Case 1: Cursor after //due:, //after:, //around: — insert date after colon
  local before = line:sub(1, cursor[2] + 1)
  local modifier_end = before:match("//[a-z]+:()$")
  if modifier_end then
    local col = modifier_end - 1
    vim.api.nvim_buf_set_text(bufnr, row, col, row, col, { date })
    vim.api.nvim_win_set_cursor(0, { row + 1, col + #date })
    return
  end

  -- Case 2: On a task line without temporal modifier — append //due:date
  if line:match("^%s*[%-*+%d.]%s*%[[%sxX><%-o!]%]") then
    if not line:match("//due:") then
      local insert_text = " //due:" .. date
      local eol = #line
      vim.api.nvim_buf_set_text(bufnr, row, eol, row, eol, { insert_text })
      vim.api.nvim_win_set_cursor(0, { row + 1, eol + #insert_text })
      return
    end
  end

  -- Case 3: Fallback — insert date at cursor
  local col = cursor[2]
  vim.api.nvim_buf_set_text(bufnr, row, col, row, col, { date })
  vim.api.nvim_win_set_cursor(0, { row + 1, col + #date })
end

return M
