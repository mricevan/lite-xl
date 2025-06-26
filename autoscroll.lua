-- mod-version:3
local core = require "core"
local DocView = require "core.docview"

local old_pressed = DocView.on_mouse_pressed
local old_released = DocView.on_mouse_released
local old_moved = DocView.on_mouse_moved

local auto_scroll_active = false
local anchor_x, anchor_y = 0, 0
local scroll_vx, scroll_vy = 0, 0
local last_scroll_time = system.get_time()

local SCROLL_MULT = 20 -- speed multiplier

function DocView:on_mouse_pressed(button, x, y, clicks)
  if button == "middle" then
    auto_scroll_active = true
    anchor_x, anchor_y = x, y
    scroll_vx, scroll_vy = 0, 0
    last_scroll_time = system.get_time()
    if core.set_cursor then core.set_cursor("sizeall") end
    return true
  end
  return old_pressed(self, button, x, y, clicks)
end

function DocView:on_mouse_released(button, x, y)
  if button == "middle" then
    auto_scroll_active = false
    scroll_vx, scroll_vy = 0, 0
    if core.set_cursor then core.set_cursor("arrow") end
    return true
  end
  return old_released(self, button, x, y)
end

function DocView:on_mouse_moved(x, y, dx, dy)
  if auto_scroll_active then
    scroll_vx = (x - anchor_x) * SCROLL_MULT
    scroll_vy = (y - anchor_y) * SCROLL_MULT
    return true
  end
  return old_moved(self, x, y, dx, dy)
end

core.add_thread(function()
  while true do
    if auto_scroll_active and core.active_view and core.active_view.scroll then
      local view = core.active_view
      if view:is(DocView) and view.doc then
        local now = system.get_time()
        local dt = now - last_scroll_time
        last_scroll_time = now

        -- Calculate vertical scroll range
        local max_scroll_y = view:get_scrollable_size()

        -- Calculate horizontal scroll range
        local max_line_len = 0
        for _, line in ipairs(view.doc.lines) do
          max_line_len = math.max(max_line_len, #line)
        end
        local char_w = view:get_font():get_width(" ")
        local max_scroll_x = math.max(0, max_line_len * char_w - view.size.x)

        -- Apply scroll with clamping
        view.scroll.to.x = math.min(math.max(view.scroll.to.x + scroll_vx * dt, 0), max_scroll_x)
        view.scroll.to.y = math.min(math.max(view.scroll.to.y + scroll_vy * dt, 0), max_scroll_y)
      end
    end
    coroutine.yield()
  end
end)
