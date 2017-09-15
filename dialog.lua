local dialog = {}

local inactivestate = {}
local typingstate = {}
local waitingstate = {}
local choosingstate = {}
local fadingstate = {}

-- The default dialog state is "inactive".
dialog.currentstate = inactivestate


-- Common subroutines

--- Require that a dialog thread exists.
-- Many states in the dialog engine resume the thread which controls
-- dialogs (dialog.thread).  These states must call requirethread()
-- at the beginning of any function which resumes dialog.thread
-- in order to ensure that the environment is sane.
local function requirethread()
    assert(dialog.thread ~= nil, 'attempted dialog without thread')
end

local function drawletterbox()
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.rectangle('fill',
                            0, virtualheight - 30,
                            virtualwidth, 30)
end


-- Inactive state
function inactivestate.draw()
    drawletterbox()
end


-- Typing state

function typingstate.update()
    assert(dialog.lettersshown ~= nil, 'dialog.lettersshown is undefined')

    if dialog.lettersshown < #dialog.currentmessage then
        bloop:stop()
        dialog.lettersshown = dialog.lettersshown + 1
        bloop:play()

        if dialog.lettersshown == #dialog.currentmessage then
            dialog.currentstate = waitingstate
        end
    end
end

function typingstate.draw()
    assert(dialog.currentmessage ~= nil, 'dialog.currentmessage is nil')
    assert(dialog.lettersshown ~= nil, 'dialog.lettersshown is nil')

    drawletterbox()

    love.graphics.setFont(font)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(string.sub(dialog.currentmessage,
                                   0, dialog.lettersshown),
                        0, virtualheight - 30)
end


-- Waiting state

function waitingstate.draw()
    assert(dialog.currentmessage ~= nil, 'dialog.currentmessage is nil')

    drawletterbox()

    love.graphics.setFont(font)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(dialog.currentmessage, 0, 90)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.rectangle('fill', virtualwidth - 16, virtualheight - 16, 16, 16)
end

function waitingstate.mousepressed(x, y, button, istouch)
    requirethread()

    coroutine.resume(dialog.thread)
end


-- Choosing state

function choosingstate.draw()
    assert(dialog.choices ~= nil, 'dialog.choices is nil')

    drawletterbox()

    -- Draw the choices.
    love.graphics.setFont(font)

    for i, choice in ipairs(dialog.choices) do
        local yoff = (i - 1) * 10

        -- Hilight the selected choice.
        if i == dialog.selectedchoice then
            love.graphics.setColor(0, 0, 255, 255)
            love.graphics.rectangle('fill',
                                    0, virtualheight - 30 + yoff,
                                    virtualwidth, 10)
        end

        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(dialog.choices[i], 0, virtualheight - 30 + yoff)
    end
end

function choosingstate.mousemoved(x, y, dx, dy, istouch)
    assert(dialog.choices ~= nil, 'dialog.choices is nil')

    x = x / scalefactor
    y = y / scalefactor

    if y < virtualheight - 30 or y > virtualheight
       or x < 0 or x > virtualwidth then
        dialog.selectedchoice = nil
    else
        dialog.selectedchoice = math.floor((y - virtualheight + 30) / 10) + 1

        if dialog.selectedchoice > #dialog.choices then
            dialog.selectedchoice = nil
        end
    end
end

function choosingstate.mousepressed(x, y, button, istouch)
    requirethread()

    if dialog.selectedchoice then
        coroutine.resume(dialog.thread, dialog.selectedchoice)
    end
end


-- Fading state

function fadingstate.update()
    requirethread()
    assert(dialog.fadedirection ~= nil, 'dialog.fadedirection is undefined')
    assert(dialog.fadeopacity ~= nil, 'dialog.fadeopacity is undefined')
    assert(dialog.fadeduration ~= nil, 'dialog.fadeduration is undefined')

    local direction = 0

    if dialog.fadedirection == 'in' then
        direction = -1
    else
        direction = 1
    end

    local diff = (255 / dialog.fadeduration) * direction

    dialog.fadeopacity = dialog.fadeopacity + diff

    if dialog.fadeopacity < 0 then
        dialog.fadeopacity = 0
    elseif dialog.fadeopacity > 255 then
        dialog.fadeopacity = 255
    end

    if dialog.fadeopacity == 0 or dialog.fadeopacity == 255 then
        coroutine.resume(dialog.thread)
    end
end

function fadingstate.draw()
    assert(dialog.fadeopacity ~= nil, 'dialog.fadeopacity is nil')

    drawletterbox()

    love.graphics.setColor(0, 0, 0, dialog.fadeopacity)
    love.graphics.rectangle('fill', 0, 0, virtualwidth, virtualheight)
end


--- Show arbitrary text in the dialog box when the dialog is inactive.
-- @param str  the string to show
function dialog.showtext(str)
    love.graphics.print(str, 0, virtualheight - 30)
end


-- Generate dialog callbacks (e.g., dialog.draw, dialog.update)

do
    local function donothing() end

    local function runifdefined(proc, ...)
        if proc == nil then
            proc = donothing
        end

        proc(...)
    end

    local function statecallerproc(name)
        return function (...)
            runifdefined(dialog.currentstate[name], ...)
        end
    end

    dialog.update       = statecallerproc('update')
    dialog.draw         = statecallerproc('draw')
    dialog.mousemoved   = statecallerproc('mousemoved')
    dialog.mousepressed = statecallerproc('mousepressed')
    dialog.keypressed   = statecallerproc('keypressed')
end


-- Dialog operators

function dialog.say(str)
    dialog.lettersshown = 0
    dialog.currentmessage = str
    dialog.currentstate = typingstate
    coroutine.yield()
    dialog.lettersshown = nil
    dialog.currentmessage = nil
    dialog.currentstate = inactivestate
end

function dialog.choose(...)
    dialog.choices = {...}
    dialog.selectedchoice = nil
    dialog.currentstate = choosingstate
    local result = coroutine.yield()
    dialog.choices = nil
    dialog.selectedchoice = nil
    dialog.currentstate = inactivestate
    return result
end

function dialog.fadein(duration)
    dialog.fadeopacity = 255
    dialog.fadedirection = 'in'
    dialog.fadeduration = duration
    dialog.currentstate = fadingstate
    coroutine.yield()
    dialog.fadeopacity = nil
    dialog.fadedirection = nil
    dialog.fadeduration = nil
    dialog.currentstate = inactivestate
end

function dialog.fadeout(duration)
    dialog.fadeopacity = 0
    dialog.fadedirection = 'out'
    dialog.fadeduration = duration
    dialog.currentstate = fadingstate
    coroutine.yield()
    dialog.fadeopacity = nil
    dialog.fadedirection = nil
    dialog.fadeduration = nil
    dialog.currentstate = inactivestate
end

--- Start a dialog.
-- @param action  the action of the dialog
function dialog.start(action)
    dialog.thread = coroutine.create(action)
    coroutine.resume(dialog.thread)
end

--- Return whether the dialog system is fading.
-- @return whether the dialog system is fading
local function isfading()
    return dialog.currentstate == fadingstate
end

--- Return whether a choice is being presented to the user.
-- @return whether a choice is being presented to the user
local function isgivingchoice()
    return dialog.currentstate == choosingstate
end

--- Return whether a dialog is currently active.
-- @return whether it is active
function dialog.isactive()
    return dialog.currentstate ~= inactivestate
end

--- Return whether the current dialog is grabbing the user input.
-- @return  whether the dialog is grabbing the user input
function dialog.isgrabbing()
    return dialog.currentstate == waitingstate
           or dialog.currentstate == choosingstate
end

return dialog
