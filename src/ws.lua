local ws, err = http.websocket("ws://url:port")

if err then
    error("ws connection failed")
end

while true do
    local message = ws.receive()
    if message == nil then
        break
    end
    local obj = json.decode(message)
end