-- mod-version:3
local core = require "core"

local keymap = require "core.keymap"
local love_executable = "love ."  -- change this path if needed.

keymap.add({
  ["ctrl+r"] = function()
core.log("Running script")
system.exec(love_executable)
  end
})
