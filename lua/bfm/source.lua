--- blink.cmp completion source for BFM syntax
local source = {}

function source.new(opts, config)
  return setmetatable({}, { __index = source })
end

function source:enabled()
  return vim.bo.filetype == "markdown"
end

function source:get_trigger_characters()
  return { "@", "/" }
end

function source:get_completions(ctx, callback)
  local context = require("bfm.context")
  local cursor = context.get_cursor_context()

  if cursor.type == "directive_open" then
    callback(require("bfm.completion.directives").complete_params(cursor))
  elseif cursor.type == "block_start" and cursor.trigger == "@" then
    callback(require("bfm.completion.directives").complete_names())
  elseif cursor.type == "modifier" then
    callback(require("bfm.completion.modifiers").complete(cursor))
  elseif cursor.type == "mention" then
    require("bfm.completion.mentions").complete(callback)
  else
    callback({ items = {}, is_incomplete_forward = false, is_incomplete_backward = false })
  end
end

return source
