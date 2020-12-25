local function printUsage()
    print("Usage: ")
    print("stripmine <len> <branch_len>")
end

local tArgs = {...}

if (#tArgs < 2 then)
    printUsage()
    return
end

-- if (turtle.getItemDetail(1).name != "minecraft:coal")
--     print("Coal in First slot, Torches in second slot")
--     return
-- end

local function checkForOre()

end

local function checkFuel()

end

local function digLen(len)
    for i=0, i<len, i++ do
        turtle.dig()
        -- Gravel...
        while not turtle.forward() do
            turlte.dig()
        end
        turtle.digUp()
    end
end

local variables = {
    blocks_home = 0,
    oreList = [
        "minecraft:gold_ore",
        "minecraft:iron_ore",
        "minecraft:coal_ore",
        "minecraft:lapis_ore",
        "minecraft:diamond_ore",
        "minecraft:redstone_ore",
        "minecraft:emerald_ore"
    ]
}

-- main loop
while true do
    checkFuel()
end