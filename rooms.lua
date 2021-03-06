-- The master list of rooms
rooms = {}

-- Load up all the rooms.
rooms.ship = love.filesystem.load('room-ship.lua')()
rooms.city = love.filesystem.load('room-city.lua')()
rooms.dome = love.filesystem.load('room-dome.lua')()
rooms.intro = love.filesystem.load('room-intro.lua')()
rooms.call = love.filesystem.load('room-call.lua')()

--- Enter and prepare a room.
-- This procedure makes the player enter a room, but also primes the
-- room's objects for use (for example, by generating outline images).
-- @param room  the room to enter
function rooms.enter(room)
    rooms.current = room
    room.enter()
    primeobjects()
end

return rooms