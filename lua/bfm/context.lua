local M = {}

---@class BfmCursorContext
---@field type string "directive_open"|"block_start"|"modifier"|"mention"|"task_item"|"body"|"none"
---@field trigger string|nil The character(s) that triggered context
---@field directive_name string|nil Active directive name (if inside directive)
---@field node TSNode|nil The tree-sitter node at cursor
---@field line string The current line text
---@field col number Cursor column (0-indexed)
---@field partial_key string|nil Partially typed modifier key
---@field modifier_key string|nil Completed modifier key (for value completion)

---@return BfmCursorContext
function M.get_cursor_context()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""

  local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col } })

  local ctx = {
    type = "none",
    trigger = nil,
    directive_name = nil,
    node = node,
    line = line,
    col = col,
  }

  -- Walk up tree-sitter parents to find context
  local parent = node
  while parent do
    local ptype = parent:type()
    if ptype == "directive_open" then
      ctx.type = "directive_open"
      local name_node = parent:field("name")[1]
      if name_node then
        ctx.directive_name = vim.treesitter.get_node_text(name_node, bufnr)
      end
      return ctx
    elseif ptype == "directive_block" then
      ctx.type = "body"
      local open = parent:child(0)
      if open then
        local name_node = open:field("name")[1]
        if name_node then
          ctx.directive_name = vim.treesitter.get_node_text(name_node, bufnr)
        end
      end
      break
    end
    parent = parent:parent()
  end

  -- Regex fallback for in-progress typing (before tree-sitter re-parses)
  local before_cursor = line:sub(1, col + 1)

  if before_cursor:match("^%s?%s?%s?@[a-z]*$") then
    ctx.type = "block_start"
    ctx.trigger = "@"
    return ctx
  end

  if before_cursor:match("//[a-z]*$") then
    ctx.type = "modifier"
    ctx.trigger = "//"
    ctx.partial_key = before_cursor:match("//([a-z]*)$")
    return ctx
  end

  if before_cursor:match("//[a-z]+:") then
    ctx.type = "modifier"
    ctx.trigger = "//"
    ctx.modifier_key = before_cursor:match("//([a-z]+):")
    return ctx
  end

  if before_cursor:match("[%s%p]@[%w._-]*$") or before_cursor:match("^@[%w._-]*$") then
    if not before_cursor:match("^%s?%s?%s?@[a-z]*$") then
      ctx.type = "mention"
      ctx.trigger = "@"
      return ctx
    end
  end

  if line:match("^%s*[%-*+%d.]%s*%[[%sxX><%-o!]%]%s") then
    ctx.type = "task_item"
  end

  return ctx
end

--- Get the task marker position and state on a given line
---@param lnum number 1-indexed line number
---@return { col: number, state: string }|nil
function M.get_task_marker(lnum)
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  if not line then return nil end

  local start, _, state = line:find("%[([%sxX><%-o!])%]")
  if not start then return nil end

  local prefix = line:sub(1, start - 1)
  if not prefix:match("^%s*[%-*+%d%.]+%s*$") then return nil end

  return { col = start - 1, state = state:lower() }
end

--- Get directive info for the directive block containing a line
---@param lnum number 1-indexed line number
---@return { name: string, open_line: number, close_line: number, params: string }|nil
function M.get_directive_at_line(lnum)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local open_line, name, params
  for i = lnum, 1, -1 do
    local n, p = lines[i]:match("^%s*@(%a+)%s*(.*)$")
    if n and not lines[i]:match("^%s*@end") then
      open_line = i
      name = n
      params = p
      break
    end
  end

  if not open_line then return nil end

  local close_tag = "@end" .. name
  for i = open_line + 1, #lines do
    if lines[i]:match("^%s*" .. vim.pesc(close_tag)) then
      if lnum >= open_line and lnum <= i then
        return {
          name = name,
          open_line = open_line,
          close_line = i,
          params = params,
        }
      end
      break
    end
  end

  return nil
end

return M
