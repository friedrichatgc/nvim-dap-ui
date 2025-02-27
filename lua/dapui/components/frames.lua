local config = require("dapui.config")
local util = require("dapui.util")

---@class StackFrames
---@field mark_frame_map table
local StackFrames = {}

function StackFrames:new()
  local elem = { mark_frame_map = {} }
  setmetatable(elem, self)
  self.__index = self
  return elem
end

local function open_frame(frame)
  util.with_session(function(session)
    util.jump_to_frame(frame, session, true)
  end)
end

---@param canvas dapui.Canvas
function StackFrames:render(canvas, frames, indent, current_frame_id)
  indent = indent or 0
  for i, frame in ipairs(frames) do
    local is_current = frame.id == current_frame_id
    canvas:write(string.rep(" ", is_current and (indent - 1) or indent))
    if is_current then
      canvas:write(config.icons().current_frame)
    end

    if frame.source ~= nil then
      local file_name = frame.source.name or frame.source.path or "<unknown>"
      local source_name = util.pretty_name(file_name)
      canvas:write(source_name, { group = "DapUISource" })
    end

    if frame.line ~= nil then
      canvas:write(":")
      canvas:write(frame.line, { group = "DapUILineNumber" })
    end

    if frame.source ~= nil or frame.line ~= nil then
      canvas:write(" ")
    end

    canvas:write(
      frame.name,
      { group = frame.id == current_frame_id and "DapUICurrentFrameName" or "DapUIFrameName" }
    )

    canvas:add_mapping(config.actions.OPEN, util.partial(open_frame, frame))
    if i < #frames then
      canvas:write("\n")
    end
  end
end

---@return StackFrames
return function()
  return StackFrames:new()
end
