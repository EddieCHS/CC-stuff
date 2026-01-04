DIRECTION=0

local function digIf()
    if turtle.detect() then
        turtle.dig()
    end
end

local function assertDirection(target)
    while not target==DIRECTION do
        turtle.turnRight()
    end
end

local function distance(target)
    local pos = {}
    local diff = {}
    pos[1], pos[2], pos[3] = gps.locate()
    for i=1,3,1 do
        if target[i]==nil then
            diff[i]=0
        else
            diff[i] = target[i] - pos[i]
        end
    end
    return diff
end

local function facing()
    local startPos = {}
    local endPos = {}
    startPos[1], startPos[2], startPos[3] = gps.locate()
    digIf()
    turtle.forward()
    endPos[1], endPos[2], endPos[3] = gps.locate()
    turtle.back()
    
    xDiff=endPos[1]-startPos[1]
    zDiff=endPos[3]-startPos[3]
    if xDiff == 1 then
        DIRECTION = 1
    elseif xDiff == -1 then
        DIRECTION = 3
    elseif zDiff == 1 then
        DIRECTION = 2
    elseif zDiff == -1 then
        DIRECTION = 0
    end
end

local function moveFB(length)
    startDir = DIRECTION
    if length<0 then
        turtle.turnLeft()
        turtle.turnLeft()
        length=-1*length
    end
    print("start move ",length)
    for i=0,length,1 do
        digIf()
        print("moving")
        turtle.forward()
    end

    assertDirection(startDir)
end

local function moveLR(length)
    if length>0 then
        turtle.turnLeft()
        moveFB(length)
        turtle.turnRight()
    else
         turtle.turnRight()
         moveFB(-1*length)
         turtle.turnLeft()
    end
    
end

local function moveUP(length)
    local reverse = false
    if length>0 then
        reverse = true
        length=-1*length
    end

    for i=1,length,1 do
        if reverse then
            turtle.down()
        else
            turtle.up()
        end
    end
end

local function directionalMove(lenght,direction)
    assertDirection(direction)
    for i=1,length,1 do
        digIf() 
        turtle.forward()
    end
end

local function moveTo(target)
    local move = distance(target)
    if move[1]>0 then
        directionalMove(move[1],1)
    else
        directionalMove(move[1]*-1,3)
    end
    if move[3]>0 then
        directionalMove(move[3]*-1,0)
    else
        directionalMove(move[3],2)
    end
    --[[
    print("moving: ",move[1]," ",move[2]," ",move[3])
    moveFB(move[3])
    moveLR(move[1])
    moveUP(move[2])]]--
end

local function dig(x,z)
    local pos = {}
    pos[1], pos[2], pos[3] = gps.locate()
    print(x,z)
    moveTo({x-pos[1],nil,z+pos[3]})
    turtle.digDown()

    --[[
    print(x,z)
    assert(loadfile("moveTo.lua"))(home[1]+x,home[2],home[3]+z)
    dofile("digDown.lua")
    turtle.select(1)
    turtle.placeDown()

    assert(loadfile("/rom/programs/turtle/refuel.lua"))("all")
    if turtle.getFuelLevel() < 1000 then
        assert(loadfile("moveTo.lua"))(home[1],home[2],home[3])
        print("fuel low")
        io.read()
    end

    if turtle.getItemCount(16) > 0 then
        assert(loadfile("moveTo.lua"))(home[1],home[2],home[3])
        turtle.turnLeft()
        turtle.turnLeft()
        dofile("dumpInventory.lua")
        turtle.turnLeft()
        turtle.turnLeft()
    end]]--
end

function localMove(target)
    local pos = {X,nil,Z}
    local diff = {}
    for i=1,3,1 do
        if target[i]==nil then
            diff[i]=0
        else
            diff[i] = target[i] - pos[i]
        end
    end

    moveFB(diff[3])
    moveLR(diff[1])
    X=target[1]
    Z=target[3]
end

X=0
Z=0
facing()
print(DIRECTION)
--print("moooving")
moveTo({-335,16,439})
--[[
i=0
while true do
    x=0
    z=i
    for x=0,i,1 do
        localMove({x,nil,z})
    end
    x=i
    z=1
    for z=i-1,0,-1 do
        localMove({x,nil,z})
    end
    i=i+1
end]]--