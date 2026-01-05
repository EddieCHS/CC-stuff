

DIRECTION=0
HOME={0,0,0}
X=0
Z=0

local function digIf()
    if turtle.detect() then
        turtle.dig()
    end
end
local function digUpIf()
    if turtle.detectUp() then
        turtle.digUp()
    end
end
local function digDownIf()
    if turtle.detectDown() then
        turtle.digDown()
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
    localDirectionOffset=0
    local blocked=detect()
    for i=1,4,1 do
        if not blocked then
            break
        end
        turtle.turnRight()
        DIRECTION=DIRECTION+1
        blocked=detect()
    end

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
        DIRECTION = (DIRECTION+1)%4
    elseif xDiff == -1 then
        DIRECTION = (DIRECTION+3)%4
    elseif zDiff == 1 then
        DIRECTION = (DIRECTION+2)%4
    elseif zDiff == -1 then
        DIRECTION = (DIRECTION+0)%4
    end
end

local function directionalMove(length,direction)
    assertDirection(direction)
    for i=1,length,1 do
        digIf()
        digUpIf()
        turtle.forward()
        digUpIf()
    end
end

function lateralMove(length)
    if length>0 then
        for i=1,length,1 do
            digUpIf()
            turtle.up()
        end
    elseif length<0 then
        for i=1,length*-1,1 do
            digDownIf()
            turtle.down()
        end
    end
end

local function moveTo(target)
    local move = distance(target)
    if move[1]>0 then
        directionalMove(move[1],1)
    elseif move[1]<0 then
        directionalMove(move[1]*-1,3)
    end
    if move[3]>0 then
        directionalMove(move[3],2)
    elseif move[3]<0 then
        directionalMove(move[3]*-1,0)
    end

    lateralMove(move[2])
end

local function refuel()
    local suckStatus = true
    while suckStatus do
        suckStatus=turtle.suck()
    end

    for i=2,16,1 do
        turtle.select(i)
        turtle.refuel(getItemCount(i))
    end

    for i=2,16,1 do
        turtle.select(i)
        turtle.drop()
    end
end

local function fuel()
    if turtle.getFuelLevel() < 1000 then
        moveTo(HOME)
        assertDirection((START_DIRECTION+1)%4)

        local fuelStatus=turtle.getFuelLevel()
        while fuelStatus<20000 do
            refuel()
            fuelStatus=turtle.getFuelLevel()
            sleep(10)
        end
    end
    turtle.select(1)
    turtle.placeDown()
end

local function inventory()
    if turtle.getItemCount(12) > 0 then
        moveTo(HOME)
        assertDirection((START_DIRECTION+2)%4)
        for i=2,16,1 do
            turtle.select(i)
            turtle.drop()
        end
    end
end

local function dig()
    local pos = {}
    pos[1], pos[2], pos[3] = gps.locate()
    local has_block, data = turtle.inspectDown()

    if pos[2] == HOME[2] and data.name ~= "minecraft:cobblestone" then
        lateralMove(-2)
        turtle.select(1)
        turtle.placeUp()
        moveTo({nil,-59,nil})
    else
        moveTo({nil,HOME[2],nil})
        turtle.select(1)
        turtle.placeDown()
    end

    if pos[2] == HOME[2] then
        inventory()
        fuel()
    end
end

facing()
START_DIRECTION=DIRECTION
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
        --dig()
    end
    x=i
    z=1
    for z=i-1,0,-1 do
        moveTo({(X*x)+HOME[1],nil,(Z*z)+HOME[3]})
        --dig()
    end
    i=i+1
end