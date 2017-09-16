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
                local result = choose('|Look at the hatch.',
                                      '@Go through the hatch..',
                                      '$Talk to the hatch.',
                                      'Nevermind.')

                if result == 1 then
                    say 'You meditate on the word painted\non the hatch.  Is it a command?\nA suggestion?  A declaration?'
                elseif result == 2 then
                    if tookthenotebook then
                        if not hasleftshipbefore then
                            say 'Let\'s go!'
                            hasleftshipbefore = true
                        end

                        rooms.enter(rooms.city)
                    else
                        say 'You still need your notebook.'
                    end
                elseif result == 3 then
                    say 'You ask the hatch whether it considers\nitself to be *between* the walls\nor *in* the walls.  The hatch is not amused.'
                end

            end
        },
        comm = {
            xoff = 37,
            yoff = 45,
            name = 'You see your computaterm.',
            image = love.graphics.newImage('images/commobj.png'),
            action = function ()
                local result = choose('|Look at the computaterm.',
                                      '@Use the computaterm.',
                                      '$Talk to the computaterm.',
                                      'Nevermind.')

                if result == 1 then
                    say 'This baby\'s a BYTH surplus issue, standard\nweight computaplex with a preinstalled\nParoliware BIOS.'
                    say 'Long story short, it\'s like a video phone\nand you don\'t know how to make it do\nanything else.'
                elseif result == 2 then
                    say 'The chairman would probably kill you\nif you called him.'
                    say '...'

                    local result = choose('@Call the chairman.', 'Back away slowly.')

                    if result == 1 then
                        rooms.enter(rooms.call)
                    end
                elseif result == 3 then
                    say 'The dormant cathode ray emitters\nbehind the glass turn out to be\nexcellent listeners.'
                end
            end
        },
        sword = {
            xoff = 10,
            yoff = 9,
            name = 'You see your katana.',
            image = love.graphics.newImage('images/sword.png'),
            action = function ()
                local result = choose('|Look at the katana.',
                                      '@Use the katana.',
                                      '$Talk to the katana.',
                                      'Nevermind.')

                if result == 1 then

                    say 'You got this for Christmas\nafter graduating.'
                    say 'You\'re sure that it would be\ndeadly if you were trained...'
                elseif result == 2 then
                    say 'You almost go full on samurai\nbefore you remember that your\nPsychic Amp is probably more\npowerful than the sword.'
                elseif result == 3 then
                    say 'You attempt a few phrases you\nheard on an anime.  Nevertheless,\nthe spirit within the katana\ndoes not answer you.'
                end
            end
        },
        notebook = {
            xoff = 29,
            yoff = 52,
            name = 'You see your notebook.',
            image = love.graphics.newImage('images/notebook.png'),
            action = function ()
                say 'With this notebook, you can note incidents.'
                playconfirm()
                takenotebook()
            end
        },
        books = {
            xoff = 31,
            yoff = 57,
            name = 'You see a small library of novels.',
            image = love.graphics.newImage('images/books.png'),
            action = function ()
                local result = choose('|Look at the books.',
                                      '@Take the books.',
                                      '$Talk to the books.',
                                      'Nevermind.')

                if result == 1 then
                    say 'You read one of the spines...\n*Valiant Shield*, by R. Sugar.'
                elseif result == 2 then
                    say 'Though the library is small,\nit\'s probably not convenient\nto carry.'
                else
                    say 'You decide to tell the books\na story of your own.\n\'Once upon a time, on a rock\norbiting Earth...\''
                end
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
