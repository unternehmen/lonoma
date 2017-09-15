local room = {}

function room.enter()
    -- switch to ship music and backdrop
    switchbgmusic(worldmapmusic)
    backdrop = city

    -- define room objects
    objects = {}

    objects.ship = {
        xoff = 111,
        yoff = 62,
        name = 'Home, sweet home.',
        image = love.graphics.newImage('images/worldmap-nearshipobj.png'),
        action = function ()
            local result = choose('@Enter the ship.', 'Nevermind.')

            if result == 1 then
                rooms.enter(rooms.ship)
            end
        end
    }

    objects.dome = {
        xoff = 27,
        yoff = 11,
        name = 'You see the Capital Dome.',
        image = love.graphics.newImage('images/worldmap-domeobj.png'),
        action = function ()
            say 'Looks like this is the\nhub of the city.'
            say 'Should I go in?'

            local result = choose('@Enter the dome.', 'Nevermind.')

            if result == 1 then
                rooms.enter(rooms.dome)
            end
        end
    }
end

return room