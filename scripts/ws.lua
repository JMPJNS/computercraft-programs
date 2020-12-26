local ws, err = http.websocket("ws://jmp.blue:3333")

if err then
    error(err)
end

print("starting")

label = os.getComputerLabel()

ws.send(textutils.serializeJSON({label=label, login=true}))

while true do
    local message = ws.receive()
    if message == nil then
        break
    end

    data = textutils.unserializeJSON(message)
    print(message)
    
    if data.target = label
        ex = "return function() return " .. data.req .. " end"
        local func, err = load(ex)

        if func then
            local ok, callable = pcall(func)
            if ok then
                res = callable()
                ws.send({label=label, res=res, req=data.req, ts=data.ts})
            else
                ws.send("Execution error:", callable)
            end
            else
            ws.send("Compilation error:", err)
        end
    end
end