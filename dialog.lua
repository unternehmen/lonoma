-- dialog with coroutines

local dialog = {
    lettersshown = nil,
    currentmessage = nil,
    thread = nil,
    choices = nil,
    selectedchoice = nil
}

function dialog.say(str)
    dialog.lettersshown = 0
    dialog.currentmessage = str
    coroutine.yield()
    dialog.lettersshown = nil
    dialog.currentmessage = nil
end

function dialog.choose(...)
    dialog.choices = {...}
    dialog.selectedchoice = nil
    local result = coroutine.yield()
    dialog.choices = nil
    dialog.selectedchoice = nil
    return result
end

function dialog.fadein(duration)
    dialog.fadeopacity = 255
    dialog.fadedirection = 'in'
    dialog.fadeduration = duration
    coroutine.yield()
    dialog.fadeopacity = nil
    dialog.fadedirection = nil
    dialog.fadeduration = nil
end

function dialog.fadeout(duration)
    dialog.fadeopacity = 0
    dialog.fadedirection = 'out'
    dialog.fadeduration = duration
    coroutine.yield()
    dialog.fadeopacity = nil
    dialog.fadedirection = nil
    dialog.fadeduration = nil
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
    return dialog.fadeopacity       ~= nil
           and dialog.fadedirection ~= nil
           and dialog.fadeduration  ~= nil
end

--- Return whether a choice is being presented to the user.
-- @return whether a choice is being presented to the user
local function isgivingchoice()
    return dialog.choices ~= nil
end

--- Return whether a dialog is currently active.
-- @return whether it is active
function dialog.dialogisactive()
    return dialog.currentmessage ~= nil or isgivingchoice() or isfading()
end

--- Return whether the current dialog is waiting for user input.
-- @return  whether the dialog is waiting for user input
function dialog.dialogiswaiting()
    return dialog.dialogisactive()
           and not isfading()
           and (isgivingchoice()
                or dialog.lettersshown == #dialog.currentmessage)
end

--- Activate the dialog in both message and choice mode.
function dialog.handleactivate()
    if isgivingchoice() then
        if dialog.selectedchoice then
            coroutine.resume(dialog.thread, dialog.selectedchoice)
        end
    elseif not isfading() then
        coroutine.resume(dialog.thread)
    end
end

--- Handle mouse movement.
-- This should be run when dialogs are active so that the dialog can
-- use mouse movement information (e.g., when presenting a choice).
-- @param x the x position of the cursor
-- @param y the y position of the cursor
-- @param dx the change in the x position of the cursor
-- @param dy the change in the y position of the cursor
-- @param istouch whether the mouse is a touchscreen
function dialog.handlemousemoved(x, y, dx, dy, istouch)
    x = x / scalefactor
    y = y / scalefactor
   
    if isgivingchoice() then
        local numberofchoices = #dialog.choices
   
        if y < virtualheight - 30 or y > virtualheight
           or x < 0 or x > virtualwidth then
            dialog.selectedchoice = nil
        else
            dialog.selectedchoice = math.floor((y - virtualheight + 30) / 10)
                                    + 1
            if dialog.selectedchoice > numberofchoices then
                dialog.selectedchoice = nil
            end
        end
    end
end

--- Update the state of the dialog.
-- When a dialog is active and the message is not completely shown,
-- this shows more letters and plays a sound.  This should be run
-- every frame or every few frames in any context in which a dialog
-- may appear.
function dialog.update()
    if isfading() then
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
    elseif dialog.dialogisactive() and not isgivingchoice() then
        if dialog.lettersshown < #dialog.currentmessage then
            bloop:stop()
            dialog.lettersshown = dialog.lettersshown + 1
            bloop:play()
        end
    end
end

--- Draw the dialog box and any text within it.
-- This draws the dialog's black box and dialog text within it.
-- This only draws text if a dialog is currently active.
function dialog.draw()
    -- Draw fade, if necessary
    if isfading() then
        love.graphics.setColor(0, 0, 0, dialog.fadeopacity)
        love.graphics.rectangle('fill', 0, 0, virtualwidth, virtualheight)
    end

    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.rectangle('fill', 0, virtualheight - 30,
                            virtualwidth, 30)
    love.graphics.setFont(font)
    love.graphics.setColor(255, 255, 255, 255)
   
    if isgivingchoice() then
        -- Draw the choices.
        for i, choice in ipairs(dialog.choices) do
            local yoff = (i - 1) * 10
            if i == dialog.selectedchoice then
                love.graphics.setColor(0, 0, 255, 255)
                love.graphics.rectangle('fill',
                                        0, virtualheight - 30 + yoff,
                                        virtualwidth, 10)
            end
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.print(dialog.choices[i], 0, virtualheight - 30 + yoff)
        end
    elseif dialog.dialogisactive() and not isfading() then
        -- Draw the current message of the dialog.
        love.graphics.print(string.sub(dialog.currentmessage,
                                       0, dialog.lettersshown),
                            0, 90)
    end
end

--- Show arbitrary text in the dialog box.
-- This has no effect on dialog.draw() or the currently active dialog.
-- @param str  the string to show
function dialog.showtext(str)
    love.graphics.print(str, 0, virtualheight - 30)
end

return dialog