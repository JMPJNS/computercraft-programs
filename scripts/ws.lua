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
    local func = load(message)
    ws.send(func())
end