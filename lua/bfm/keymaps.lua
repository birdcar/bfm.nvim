local M = {}

local default_keymaps = {
  cycle_forward = "<leader>tt",
  cycle_backward = "<leader>tT",
  insert_date = "<leader>td",
}

function M.setup(bufnr)
  local config = require("bfm.config").get()
  local maps = vim.tbl_deep_extend("force", default_keymaps, config.keymaps or {})

  local cycling = require("bfm.cycling")
  local dates = require("bfm.dates")

  if maps.cycle_forward then
    vim.keymap.set("n", maps.cycle_forward, function()
      cycling.cycle_forward()
    end, { buffer = bufnr, desc = "BFM: Cycle task state forward" })

    vim.keymap.set("v", maps.cycle_forward, function()
      cycling.cycle_forward({ visual = true })
    end, { buffer = bufnr, desc = "BFM: Cycle task states forward" })
  end

  if maps.cycle_backward then
    vim.keymap.set("n", maps.cycle_backward, function()
      cycling.cycle_backward()
    end, { buffer = bufnr, desc = "BFM: Cycle task state backward" })

    vim.keymap.set("v", maps.cycle_backward, function()
      cycling.cycle_backward({ visual = true })
    end, { buffer = bufnr, desc = "BFM: Cycle task states backward" })
  end

  if maps.insert_date then
    vim.keymap.set("n", maps.insert_date, function()
      dates.insert_date()
    end, { buffer = bufnr, desc = "BFM: Insert today's date" })
  end
end

return M
