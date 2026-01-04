DIRECTION=0
HOME={-332,16,437}
X=0
Z=0

local function digIf()
    if turtle.detect() then
        turtle.dig()
    end
end

local function assertDirection(target)
    while target~=DIRECTION do
        turtle.turnRight()
        DIRECTION=(DIRECTION+1)%4
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

local function directionalMove(length,direction)
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
        directionalMove(move[3],2)
    else
        directionalMove(move[3]*-1,0)
    end
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

facing()


if DIRECTION==0 then
    X=-1
    Z=-1
elseif DIRECTION==1 then
    X=1
    Z=-1
elseif DIRECTION==2 then
    X=1
    Z=1
elseif DIRECTION==3 then
    X=-1
    Z=1
end

i=0
while true do
    x=0
    z=i
    for x=0,i,1 do
        moveTo({(X*x)+HOME[1],nil,(Z*z)+HOME[3]})
        turtle.digDown()
    end
    x=i
    z=1
    for z=i-1,0,-1 do
        moveTo({(X*x)+HOME[1],nil,(Z*z)+HOME[3]})
        turtle.digDown()
    end
    i=i+1
end