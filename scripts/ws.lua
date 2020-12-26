local ws, err = http.websocket("ws://jmp.blue:3333")

if err then
    error(err)
end

print("starting")

ws.send("yes")

while true do
    local message = ws.receive()
    if message == nil then
        break
    end

    local func, err = load("return function() return " + message + " end")

    if func then
        local ok, callable = pcall(func)
        if ok then
            ws.send(callable())
        else
            ws.send("Execution error:", callable)
        end
        else
        ws.send("Compilation error:", err)
    end
end