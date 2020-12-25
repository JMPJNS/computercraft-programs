-- OreQuarry by martin2250 (https://www.github.com/martin2250/), edited by JMPJNS
-- This program will dig out a square from layer 5 to the specified maximum height
-- It will skip two layers a time, but it will still dig out any block not listed in badBlocks,
-- so it will remove 100% of the ores in the column while being very time and fuel efficient
-- for technical reasons, the size has to be a multiple of two

-- [][][][][][][][][][]
-- [][][][][][][][][][]
-- [][][][][][][][][][]
-- [][][][][][][][][][]
-- [][][][][][][][][][]
-- [][][][][][][][][][]
-- [][][][][][][][][][]
-- [][][][][][][][][][]
-- [][][][][][][][][][]
-- /\[][][][][][][][][]
-- C

-- [] : area that is mined out (in this case 10 by 10)
-- /\ : initial position and direction of the turtle
-- C  : a chest (stack multiple chests on top of eachother for more space)

-- for very space efficient mining, use a pattern similar to this:

  -- /\
-- < CC >
  -- \/


  if not turtle then
	error("Only runs on turtles")
end

local x, y, z = 0, 0, nil
local direction = 0
local maxHeight, size, startHeight = nil, nil, nil
local maxChestHeight = 8
local badBlocks = {
["minecraft:cobblestone"]=true,
["minecraft:stone"]=true,
["minecraft:dirt"]=true,
["minecraft:gravel"]=true,
["minecraft:sand"]=true,
["minecraft:bedrock"]=true,
["minecraft:flint"]=true,
["minecraft:rotten_flesh"]=true,
["minecraft:sandstone"]=true,
["minecraft:diorite"]=true,
["minecraft:andesite"]=true,
["chisel:limestone"]=true,
["chisel:diorite"]=true,
["chisel:marble"]=true,
["minecraft:granite"]=true,
["minecraft:andesite"]=true,
["minecraft:diorite"]=true,
["byg:rocky_stone"]=true,
["byg:scoria_cobblestone"]=true,
["byg:soapstone"]=true
}

local currentLayer

local chatBox = peripheral.find("chatbox")

function say(message)
	print(message)
	
	if chatBox then
		pcall(chatBox.say, message)	--prevent too many messages error
	end
end

--			0				y+
--		3	^	1		x-		x+
--			2				y-

function turnTo(newDirection)
	while newDirection < 0 do
		newDirection = newDirection + 4
	end
	newDirection = newDirection % 4
	
	if (newDirection - direction) % 4 > 1 then
		while direction ~= newDirection do
			turtle.turnLeft()
			direction = (direction + 3) % 4
		end
	else
		while direction ~= newDirection do
			turtle.turnRight()
			direction = (direction + 1) % 4
		end
	end	
end

function fastSelect(i)
	if turtle.getSelectedSlot() ~= i then
		turtle.select(i)
	end
end

function move(moveFunc, digFunc, attackFunc)
	local failCount = 0
	
	digFunc()
	
	while not moveFunc() do
		digFunc()
		attackFunc()
		sleep(0.25)
		
		failCount = failCount + 1
		
		if failCount == 100 then
			say("Unable to move")
		end
	end
end

function up()
	move(turtle.up, turtle.digUp, turtle.attackUp)
	z = z + 1
end

function down()
	move(turtle.down, turtle.digDown, turtle.attackDown)
	z = z - 1
end

function forward()
	move(turtle.forward, turtle.dig, turtle.attack)
	
	if direction == 0 then
		y = y + 1
	elseif direction == 1 then
		x = x + 1
	elseif direction == 2 then
		y = y - 1
	else
		x = x - 1
	end	
end

function check()
	local success, data = turtle.inspectUp()
	if success and not badBlocks[data.name] then
		fastSelect(1)
		turtle.digUp()
	end
	success, data = turtle.inspectDown()
	if success and not badBlocks[data.name] then
		fastSelect(1)
		turtle.digDown()
	end
end

function gotoZ(newZ)
	while z < newZ do
		up()
	end
	while z > newZ do
		down()
	end	
end

function dropAndSortItems()
	say("claning up inventory")
		
	for i=1, 16 do
		local data = turtle.getItemDetail(i)
		
		if data and badBlocks[data.name] then
			fastSelect(i)
			turtle.dropDown()
		else
			for ii=1, i do
				local other = turtle.getItemDetail(ii)
				if not other or (other.name == data.name and turtle.getItemSpace(ii) > 0) then
					fastSelect(i)
					turtle.transferTo(ii)
					if turtle.getItemCount(i) == 0 then
						break
					end
				end
			end
		end
	end
end

function emptyInventory(force)
	if not force then
		if turtle.getItemCount(16) == 0 then
			return
		end
	end
		
	dropAndSortItems()
	
	if not force then
		if turtle.getItemCount(15) == 0 then
			fastSelect(1)
			return
		end
	end
	
	say("returning to the surface to drop off items")
	
	local oldX, oldY, oldZ, oldDir = x, y, z, direction
	
	turnTo(3)
	
	while x > 0 do
		forward()
	end
	
	turnTo(2)
	
	while y > 0 do
		forward()
	end
	
	gotoZ(startHeight)

	local chestHeight = 0
	
	say("dropping inventory and refuling")
	for i=1, 16 do
		if turtle.getItemCount(i) > 0 then
			fastSelect(i)
			   turtle.refuel()
			   turtle.drop()
			-- while not turtle.drop() do
			-- 	up()
			-- 	chestHeight = chestHeight + 1
			-- 	if chestHeight > maxChestHeight then
			-- 		error("reached max chest height, stopping program")
			-- 	end
			-- end
		end
	end
	
	fastSelect(1)
	
	gotoZ(oldZ)
	
	turnTo(0)
	
	while y < oldY do
		forward()
	end
	
	turnTo(1)
	
	while x < oldX do
		forward()
	end
	
	turnTo(oldDir)
end


startHeight, size, maxHeight, currentLayer = ...

startHeight = tonumber(startHeight)
size = tonumber(size)
maxHeight = tonumber(maxHeight)
currentLayer = tonumber(currentLayer)

if not (startHeight and size) then
	print("usage: OreQuarry [Y coordinate] [Size] <Max mining height: Y-2 > <Start Height: 5>")
	print("turtle will mine a square of [size] blocks")
	print("place a vertical column of chests behind the turtle")
	return
end

startHeight = math.floor(startHeight)
z = startHeight
size = math.floor(size)

if not currentLayer then
	currentLayer = 5
end

if not maxHeight then
	maxHeight = 16
end

maxHeight = math.floor(maxHeight)
currentLayer = math.floor(currentLayer)

if size % 2 ~= 0 then
	print("Size must be multiple of 2")
	return
end

if size < 0 or startHeight < 6 or startHeight > 255 or maxHeight < 8 or maxHeight > startHeight - 2 then
	print("Bad Arguments")
	return
end



while currentLayer < maxHeight do
	say("Mining Layer " .. currentLayer)
	
	gotoZ(currentLayer)

	while true do
		turnTo((x % 2) * 2)
		
		if x % 2 == 0 then
			while y < size - 1 do
				check()
				forward()
				emptyInventory()
			end
		else
			while y > 0 do
				check()
				forward()
				emptyInventory()
			end
		end
		
		check()
		
		if x < size - 1 then
			turnTo(1)
			forward()
		else
			turnTo(3)
			
			while x > 0 do
				forward()
			end
			
			turnTo(2)
			
			while y > 0 do
				forward()
			end			
			break
		end
	end
	currentLayer = currentLayer + 3
end
dropAndSortItems()
gotoZ(startHeight)
emptyInventory(true)

say("Done")