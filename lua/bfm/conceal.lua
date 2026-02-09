local M = {}
local ns = vim.api.nvim_create_namespace("bfm_conceal")

local default_icons = {
  task = {
    [" "] = "○",
    ["x"] = "✓",
    [">"] = "→",
    ["<"] = "←",
    ["-"] = "—",
    ["o"] = "●",
    ["!"] = "!",
  },
  callout_type = {
    info = "ℹ",
    warning = "⚠",
    danger = "✘",
    success = "✓",
    note = "✎",
  },
}

local hl_map = {
  [" "] = "@bfm.task.open",
  ["x"] = "@bfm.task.done",
  [">"] = "@bfm.task.scheduled",
  ["<"] = "@bfm.task.migrated",
  ["-"] = "@bfm.task.irrelevant",
  ["o"] = "@bfm.task.event",
  ["!"] = "@bfm.task.priority",
}

function M.setup(bufnr)
  local config = require("bfm.config").get()
  if not config.conceal.enabled then return end

  M.render(bufnr)

  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function(_, buf)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          M.render(buf)
        end
      end)
    end,
  })
end

function M.render(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local config = require("bfm.config").get()
  local icons = vim.tbl_deep_extend("force", default_icons, config.conceal.icons or {})
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for i, line in ipairs(lines) do
    local row = i - 1

    -- Conceal task markers: [x] → icon
    local marker_start, marker_end, state = line:find("%[([%sxX><%-o!])%]")
    if marker_start then
      local prefix = line:sub(1, marker_start - 1)
      if prefix:match("^%s*[%-*+%d%.]+%s*$") then
        local icon = icons.task[state:lower()]
        local hl = hl_map[state:lower()]
        if icon then
          local span_width = marker_end - marker_start + 1
          local icon_width = vim.fn.strdisplaywidth(icon)
          local padding = span_width - icon_width
          local lpad = math.floor(padding / 2)
          local rpad = padding - lpad
          local text = string.rep(" ", lpad) .. icon .. string.rep(" ", rpad)
          vim.api.nvim_buf_set_extmark(bufnr, ns, row, marker_start - 1, {
            end_col = marker_end,
            virt_text = { { text, hl } },
            virt_text_pos = "overlay",
          })
        end
      end
    end

    -- Conceal directive open tags
    local dir_name, params = line:match("^%s*@(%a+)%s*(.*)$")
    if dir_name and not line:match("^%s*@end") then
      local callout_type = params:match("type=(%a+)")
      if callout_type and icons.callout_type[callout_type] then
        local type_icon = icons.callout_type[callout_type]
        vim.api.nvim_buf_set_extmark(bufnr, ns, row, #line, {
          virt_text = { { " " .. type_icon, "@comment" } },
          virt_text_pos = "eol",
        })
      end
    end

    -- Conceal directive close tags
    if line:match("^%s*@end%a+%s*$") then
      vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
        end_col = #line,
        conceal = "",
        virt_text = { { "───", "@comment" } },
        virt_text_pos = "overlay",
      })
    end
  end
end

return M
