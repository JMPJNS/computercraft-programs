while true do
	local event, button, x, y = os.pullEvent("mouse_click")
	paintutils.drawPixel(x, y, colors.pink)
end