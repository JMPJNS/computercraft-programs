local ws, err = http.websocket("ws://192.168.8.101:3333")

if err then
    error(err)
end

print("starting")

while true do
    local message = ws.receive()
    if message == nil then
        break
    end
    print(message)
end