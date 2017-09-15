local room = {}

function room.update()
    -- Update the scanline animation.
    if scanlineoffset >= -39 then
        scanlineoffset = -108
    else
        scanlineoffset = scanlineoffset + 1
    end
end

function room.draw()
    -- Draw Jyesula with the scanline effect.
    love.graphics.setCanvas(scancanvas)
        love.graphics.push()
        love.graphics.scale(0.25, 0.25)
        love.graphics.clear(0, 0, 0, 0)
       
        love.graphics.draw(scanline, 0, scanlineoffset + 69)
        love.graphics.draw(scanline, 0, scanlineoffset)
        love.graphics.pop()
    love.graphics.setCanvas()
    love.graphics.setCanvas(canvas)
        love.graphics.push()
        love.graphics.scale(0.25, 0.25)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setBlendMode('alpha')
        love.graphics.draw(jyesula, 0, 0)
        love.graphics.setBlendMode('multiply')
        love.graphics.draw(scancanvas)
        love.graphics.setBlendMode('alpha')
        love.graphics.pop()
    love.graphics.setCanvas()
    love.graphics.draw(canvas, 0, 0)
end

local function introaction()
    backdrop = love.graphics.newImage('images/comm.png')

    dialog.fadein(200)

    switchbgmusic(shipmusic)
    say 'Greetings, comrade...\nTime is short, so listen well.'
    say 'You are en route\nto the moon colony.'
    say 'I would go myself,\nbut Maya needs me.'
    say 'If, after all this time,\nthe colony is an embarassment,'
    say 'then you must remind them\nthat it is I who rule them.'
    say 'More details on how to\ndiscipline the colony'
    say 'are in the manual\nsupplied with your ship.'

    local saidfarewell = false
    while not saidfarewell do
        say 'Do you have any questions\nbefore I disconnect?'
       
        local result = choose('What is Lonoma?',
                              'Who are you?',
                              'No questions.')
       
        if result == 1 then
            say 'Lonoma is a lost territory\nof the empire.'
            say 'The first extraterrestrial\nterritory, in fact.'
            say 'However, we lost contact\nwith them centuries ago.'
            say 'Only recently have we\nmanaged to get a signal up...'
            say '... which is why you\'re\non your way right now.'
        elseif result == 2 then
            say '... Now is not the time\nfor jokes, Agent.'
        else
            saidfarewell = true
        end
    end

    say 'Anyway,'
    say 'I await your weekly report\non the colony.'
    say 'Do not contact me\nfor any other reason.'
    say 'Closing transmission...'

    dialog.fadeout(200)

    anchor:play()
    rooms.enter(rooms.ship)
end

function room.enter()
    scanlineoffset = 0

    objects = {}

    dialog.start(introaction)
end

return room