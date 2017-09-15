local room = {}

local function takenotebook()
    objects.notebook = nil
    tookthenotebook = true
end

function room.enter()
    -- switch to ship music and backdrop
    switchbgmusic(shipmusic)
    backdrop = love.graphics.newImage('images/ship.png')

    -- define room objects
    objects = {
        hatch = {
            xoff = 127,
            yoff = 2,
            name = 'You see the exit hatch.',
            image = love.graphics.newImage('images/hatch.png'),
            action = function ()
                if tookthenotebook then
                    local result = choose('@Leave the ship.',
                                          'Nevermind.')

                    if result == 1 then
                        if not hasleftshipbefore then
                            say 'Let\'s go!'
                            hasleftshipbefore = true
                        end

                        rooms.enter(rooms.city)
                    end
                else
                    say 'I still need my notebook.'
                end
            end
        },
        comm = {
            xoff = 37,
            yoff = 45,
            name = 'You see your computaterm.',
            image = love.graphics.newImage('images/commobj.png'),
            action = function ()
                say 'The chairman would kill me\nif I called him.'
                say '...'

                local result = choose('@Call the chairman.', 'Back away slowly.')

                if result == 1 then
                    rooms.enter(rooms.call)
                end
            end
        },
        sword = {
            xoff = 10,
            yoff = 9,
            name = 'You see your katana.',
            image = love.graphics.newImage('images/sword.png'),
            action = function ()
                say 'I got this for Christmas\nafter graduating.'
                say 'I\'m sure that it would be\ndeadly if I were trained...'
            end
        },
        notebook = {
            xoff = 29,
            yoff = 52,
            name = 'You see your notebook.',
            image = love.graphics.newImage('images/notebook.png'),
            action = function ()
                say 'With this notebook,\nI can note incidents.'
                playconfirm()
                takenotebook()
            end
        },
        books = {
            xoff = 31,
            yoff = 57,
            name = 'You see some books.\nThey seem hastily hand-bound.',
            image = love.graphics.newImage('images/books.png'),
            action = function ()
                say 'I printed these fanfics\nbefore the flight.'
            end
        },
        manual = {
            xoff = 43,
            yoff = 32,
            name = 'You see a manual.',
            image = love.graphics.newImage('images/manual.png'),
            action = function ()
                say 'Manual of Bythanthian Agents:\nIn honor of the Chairman'

                local result = choose('@Read the first paragraph.', 'Put down the manual')

                if result == 1 then
                    say 'Equalize the empire.\nMake examples of outliers.'
                    say 'By the grace of the\nChairman, you have a weapon.'
                    say 'The Psychic Amp is your\ntool of justice.'
                end
            end
        }
    }

    -- load the state of the room
    if tookthenotebook then
        takenotebook()
    end
end

return room