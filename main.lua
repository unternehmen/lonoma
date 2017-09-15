dialog = love.filesystem.load('dialog.lua')()
say = dialog.say
choose = dialog.choose
rooms = love.filesystem.load('rooms.lua')()

function switchbgmusic(music)
    if currentbgmusic ~= music then
        if currentbgmusic then
            currentbgmusic:stop()
        end
        currentbgmusic = music
        currentbgmusic:play()
    end
end

function love.load()
    kleft = 'left'
    kright = 'right'
    kup = 'up'
    kdown = 'down'
    kact = 'space'
    scalefactor = 4
    realwidth = 640
    realheight = 480
    virtualwidth = realwidth / scalefactor
    virtualheight = realheight / scalefactor

    -- give us a retro look when scaling pixel art
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setMode(realwidth, realheight)
    canvas = love.graphics.newCanvas(virtualwidth, virtualheight)
    scancanvas = love.graphics.newCanvas(virtualwidth, virtualheight)

    -- load music and sounds
    music   = love.audio.newSource('music/title.ogg')
    music:setLooping(true)
    shipmusic  = love.audio.newSource('music/ship.ogg')
    shipmusic:setLooping(true)
    worldmapmusic = love.audio.newSource('music/city.ogg')
    worldmapmusic:setLooping(true)
    confirm = love.audio.newSource('sounds/confirm.wav', 'static')
    bloop   = love.audio.newSource('sounds/bloop.wav', 'static')
    anchor  = love.audio.newSource('sounds/anchor.wav', 'static')
    currentbgmusic = nil

    -- debug font
    debugfont = love.graphics.newFont(14)

    -- load graphics
    comm = love.graphics.newImage('images/comm.png')
    logo = love.graphics.newImage('images/logo.png')
    font = love.graphics.newImageFont('images/font.png',
                                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ '
                                      .. 'abcdefghijklmnopqrstuvwxyz,.!?@:>\'')
    scanline = love.graphics.newImage('images/scanline.png')
    jyesula = love.graphics.newImage('images/jyesula.png')
    ship = love.graphics.newImage('images/ship.png')
    city = love.graphics.newImage('images/city.png')
    backdrop = nil

    -- start game in the title mode
    switchmode('title')
end

--- Copy (and decompress) an image and return the copy.
-- This function always returns an image with uncompressed image data.
-- @param img  the image
-- @return     the copy of the image
function copyimg(img)
    local width = img:getWidth()
    local height = img:getHeight()

    local canvas = love.graphics.newCanvas(width, height)

    love.graphics.setCanvas(canvas)
        love.graphics.push()
        love.graphics.origin()
        love.graphics.clear(0, 0, 0, 0)
        local origr, origg, origb, origa = love.graphics.getColor()
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(img, 0, 0)
        love.graphics.setColor(origr, origg, origb, origa)
        love.graphics.pop()
    love.graphics.setCanvas()

    local data = canvas:newImageData()

    return love.graphics.newImage(data)
end

--- Determine whether a pixel in an image is totally transparent.
-- @param img  the image
-- @param mx   the x position
-- @param my   the y position
-- @return     whether the pixel is transparent
function ispicked(img, x, y)
    local width = img:getWidth()
    local height = img:getHeight()

    if x < 0 or x >= width or y < 0 or y >= height then
        return false
    end

    local image = copyimg(img)
    local data = img:getData()

    local r, g, b, a = data:getPixel(x, y)

    return a ~= 0
end

--- Create an "outline" image of an image.
-- The outline is a white, 1-pixel border around each non-transparent
-- pixel of the original image.
-- The returned image has a pixel-wide transparent border around it.
-- @param img  the image
-- @return     the outline image
function outlineimage(img)
    local image = copyimg(img)
    local width = img:getWidth()
    local height = img:getHeight()
    local data = img:getData()

    local canvas = love.graphics.newCanvas(width + 2, height + 2)
    local origcanvas = love.graphics.getCanvas()
    local origr, origg, origb, origa = love.graphics.getColor()

    love.graphics.setCanvas(canvas)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.push()
        love.graphics.origin()
        love.graphics.setColor(255, 255, 255, 255)
        for x = 0, width - 1 do
            for y = 0, height - 1 do
                local r, g, b, a = data:getPixel(x, y)

                if a ~= 0 then
                    local offsets = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}};
                    for _, offset in ipairs(offsets) do
                        local nx = x + offset[1]
                        local ny = y + offset[2]

                        pixbump = 1
                        if nx >= -1 and nx < width + 1
                           and ny >= -1 and ny < height + 1
                        then
                            if nx < 0 or nx >= width
                               or ny < 0 or ny >= height
                            then
                                love.graphics.points(nx + 1, ny + 1)
                            else
                                local r, g, b, a = data:getPixel(nx, ny)
                                if a == 0 then
                                    love.graphics.points(nx + 1, ny + 1)
                                end
                            end
                        end
                    end
                end
            end
        end
        love.graphics.setColor(origr, origg, origb, origa)
        love.graphics.pop()
    if origcanvas == nil then
        love.graphics.setCanvas()
    else
        love.graphics.setCanvas(origcanvas)
    end

    local newdata = canvas:newImageData()
    return love.graphics.newImage(newdata)
end

states = {
    title = {},
    intro = {},
    play  = {}
}

function switchmode(to)
    if mode and states[mode].quit then
        states[mode].quit()
    end

    mode = to

    if states[mode].init then
        states[mode].init()
    end
end

function playconfirm()
    confirm:play()
end


-- PLAY MODE

--- Prepare the outlines and missing fields of all objects.
-- This procedure fills out the fields of all existing objects
-- if those fields are not already defined, including the outline
-- images.  You must run this after defining new objects.
-- This procedure mutates the global variable "objects".
function primeobjects()
    for key, _ in pairs(objects) do
        if objects[key].picked == nil then
            objects[key].picked = false
        end

        if objects[key].outline == nil then
            objects[key].outline = outlineimage(objects[key].image)
        end
    end
end

function states.play.init()
    -- the list of objects, things in the game world which you can click
    rooms.enter(rooms.intro)
end

function states.play.update()
    if rooms.current.update then
        rooms.current.update()
    end
    dialog.update()
end

function states.play.draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(backdrop, 0, 0)
    if rooms.current.draw then
        rooms.current.draw()
    end

    local picked = nil

    -- draw all objects
    for _, object in pairs(objects) do
        love.graphics.draw(object.image, object.xoff, object.yoff)
    end

    -- identify the picked object
    for _, object in pairs(objects) do
        if object.picked then
            picked = object
        end
    end

    -- draw an outline around the picked object
    if picked then
        love.graphics.draw(picked.outline, picked.xoff - 1, picked.yoff - 1)
    end

    -- draw the active dialog if applicable
    dialog.draw()

    -- draw the name of the picked object if there is no dialog
    if not dialog.isactive() then
        if picked then
            dialog.showtext(picked.name)
        end
    end
end

function states.play.keypressed(key)
    if dialog.isgrabbing() then
	    dialog.keypressed(key)
    end
end

function states.play.mousemoved(x, y, dx, dy, istouch)
    -- pick any object under the cursor
    if dialog.isactive() then
        dialog.mousemoved(x, y, dx, dy, istouch)
    elseif y / scalefactor < virtualheight - 30 then
        for _, object in pairs(objects) do
            object.picked = ispicked(object.image,
                                     x / scalefactor - object.xoff,
                                     y / scalefactor - object.yoff)
            picked = object.picked
        end
    else
        for _, object in pairs(objects) do
            object.picked = false
        end
    end
end

function states.play.mousepressed(x, y, button, istouch)
    -- if a dialog is waiting for the user, let it process the press
    if dialog.isgrabbing() then
        dialog.mousepressed(x, y, button, istouch)
        return
    end

    -- if a dialog is active, do nothing
    if dialog.isactive() then
        return
    end

    -- otherwise, if an object is picked, activate it
    local done = false
    for _, object in pairs(objects) do
        if object.picked and not done then
            object.picked = false

            dialog.start(object.action)

            done = true
        end
    end
end


-- title screen callbacks

function states.title.init()
    fadeopacity = 0
    switchbgmusic(music)
end

function states.title.update()
    if fadeopacity < 255 then
        fadeopacity = fadeopacity + 1
    end
end

function states.title.draw()
    love.graphics.setColor(255, 255, 255, fadeopacity)
    love.graphics.draw(logo, 0, 0)
    love.graphics.setColor(255, 255, 255, 255)
end

function startgame()
    confirm:play()
    music:stop()
    switchmode('play')
end

function states.title.keypressed(key)
    if key == kact then
        startgame()
    end
end

function states.title.mousepressed(x, y, dx, dy, istouch)
    if fadeopacity == 255 then
        startgame()
    end
end


-- main callbacks

function love.update()
    if states[mode].update then
        states[mode].update()
    end
end

function love.draw()
    love.graphics.clear()
    love.graphics.scale(scalefactor, scalefactor)
    if states[mode].draw then
        states[mode].draw()
    end
end

function love.keypressed(...)
    if states[mode].keypressed then
        states[mode].keypressed(...)
    end
end

function love.mousemoved(...)
    if states[mode].mousemoved then
        states[mode].mousemoved(...)
    end
end

function love.mousepressed(...)
    if states[mode].mousepressed then
        states[mode].mousepressed(...)
    end
end
