local watches
local name = "DAP Watches"

---@type Element
return {
  name = name,
  buf_options = {
    filetype = "dapui_watches",
    omnifunc = "v:lua.require'dap'.omnifunc",
  },
  setup = function(state)
    watches = require("dapui.components.watches")(state)
  end,
  render = function(canvas)
    watches:render(canvas)
  end,
  add_expression = function(expr)
    if not expr then
      if vim.fn.mode() == "v" then
        local start = vim.fn.getpos("v")
        local finish = vim.fn.getpos(".")
        local lines = require("dapui.util").get_selection(start, finish)
        expr = table.concat(lines, "\n")
      else
        expr = expr or vim.fn.expand("<cexpr>")
      end
    end
    watches:add_watch(expr)
  end,
}
