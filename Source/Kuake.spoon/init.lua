local obj = {
	name = "Kuake",
	version = "0.1",
	author = "Igor Karpinskiy <ik@altimho.com>",
	license = "MIT - https://opensource.org/licenses/MIT",
}
obj.__index = obj

obj.winName = "Kuake"
obj.kittyExecOptions = "--override macos_hide_from_tasks=yes --override hide_window_decorations=titlebar-and-corners"
obj.windowRect = { 0.0, 0.0, 1.0, 0.75 }

function obj:_findWindow()
	return hs.window.find(self.winName)
end

function obj:_findOrCreateWindow(cb)
	local win = self:_findWindow()

	if not win then
		os.execute("open -a kitty.app -n --args --title " .. self.winName .. " " .. self.kittyExecOptions)
		hs.timer.doAfter(1, function()
			win = self:_findWindow()
			win:application():hide()

			cb(win)
		end)
	else
		cb(win)
	end
end

function obj:_isFocused(win)
	local focused = hs.window.focusedWindow()

	return win:id() == focused:id()
end

function obj:toggle()
	self:_findOrCreateWindow(function(win)
		if win:isVisible() and self:_isFocused(win) then
			win:application():hide()
		else
			win:moveToUnit(self.windowRect, 0)
			win:focus()
		end
	end)
end

function obj:bindHotKeys(mapping)
	local spec = {
		toggle = hs.fnutils.partial(self.toggle, self),
	}
	hs.spoons.bindHotkeysToSpec(spec, mapping)

	return self
end

return obj
