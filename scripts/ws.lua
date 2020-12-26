reconnect_counter = 0
term.clear()
term.setCursorPos(1,1)

label = os.getComputerLabel()

while true do
    local ws, err = http.websocket("wss://ws.jmp.blue")

    if err then
        error(err)
    end

    print("starting " .. label .. ", reconnect " .. reconnect_counter)

    ws.send(textutils.serializeJSON({label=label, login=true}))

    while true do
        local message = ws.receive()
        if message == nil then
            print("server restarted, waiting 10 seconds for reconnect")
            os.sleep(10)
            break
        end

        data = textutils.unserializeJSON(message)
        print(message)

        if data.target == label then
            ex = "return function() return " .. data.req .. " end"
            local func, err = load(ex)

            if func then
                local ok, callable = pcall(func)
                if ok then
                    res = callable()
                    ws.send(textutils.serializeJSON({label=label, res=res, req=data.req, ts=data.ts}))
                else
                    ws.send(textutils.serializeJSON({label=label, err="Execution error", f=callable, req=data.req, ts=data.ts}))
                end
                else
                    ws.send(textutils.serializeJSON({label=label, err="Compilation error", f=err, req=data.req, ts=data.ts}))
            end
        end
    end
    reconnect_counter = reconnect_counter + 1
end