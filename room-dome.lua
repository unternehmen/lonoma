local room = {}

function room.enter()
    -- switch to ship music and backdrop
    switchbgmusic(worldmapmusic)
    backdrop = love.graphics.newImage('images/bg-dome.png')

    -- define room objects
    objects = {}

    -- load the state of the room
end

return room