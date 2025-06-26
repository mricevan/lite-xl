-- mod-version:3
local core = require "core"

local keymap = require "core.keymap"
local love_executable = "love ."

keymap.add({
  ["ctrl+r"] = function()
core.log("Running script")
system.exec(love_executable)
-- or
-- system.exec(string.format("love2d %s", core.project_dir))
-- system.exec("./script")
  end
})
