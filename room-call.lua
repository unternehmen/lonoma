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
    say 'Do you have news, Agent?'

    local result = choose('Uh...', 'Is your refridgerator running?',
                          'Apologies, wrong number.')

    if result == 2 then
        say '... I am disconnecting.'
    elseif result == 3 then
        say 'Good luck, Agent.'
    end

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