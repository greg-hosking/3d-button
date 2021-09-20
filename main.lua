function love.load()
    -- Set up color constants to make referencing and randomizing colors more straightforward
    BUTTON_COLORS = {}
    BUTTON_COLORS.GRAY = {0.5, 0.5, 0.5}
    BUTTON_COLORS.DARK_GRAY = {0.2, 0.2, 0.2}
    BUTTON_COLORS.RED = {1, 0, 0}
    BACKGROUND_COLORS = {}
    table.insert(BACKGROUND_COLORS, {0.55, 0, 0.99}) -- Purple
    table.insert(BACKGROUND_COLORS, {0.21, 0, 1}) -- Blue
    table.insert(BACKGROUND_COLORS, {0, 1, 0}) -- Green
    table.insert(BACKGROUND_COLORS, {1, 1, 0.22}) -- Yellow
    table.insert(BACKGROUND_COLORS, {1, 0.53, 0}) -- Orange
    table.insert(BACKGROUND_COLORS, {0.93, 0, 0.01}) -- Red

    tSincePrevColor = 0
    tBtwnColors = 0.25
    love.math.setRandomSeed(love.timer.getTime())

    love.window.setTitle("3D Button Proof of Concept")
    love.window.setFullscreen(false)
    W, H = love.graphics.getDimensions()

    button = createNewButton(W * 0.5, H * 0.5, W * 0.1, H * 0.1, H * 0.075, BUTTON_COLORS.RED)
    music = love.audio.newSource("music.mp3", "static")
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    tSincePrevColor = tSincePrevColor + dt
    if button.isClicked and tSincePrevColor >= tBtwnColors then
        love.graphics.setBackgroundColor(BACKGROUND_COLORS[love.math.random(#BACKGROUND_COLORS)])
        tSincePrevColor = 0
    elseif not button.isClicked then
        love.graphics.setBackgroundColor(0, 0, 0)
    end

    button.update()
end

function love.draw()
    button.draw()
end

function love.mousepressed(x, y)
    button.onMouseDown()
end

function love.mousereleased(x, y)
    button.onMouseUp()
end

function createNewButton(x, y, rx, ry, h, color)
    local button = {}

    button.x = x
    button.y = y
    button.rx = rx
    button.ry = ry

    button.h = {}
    button.h.default = h
    button.h.onMouseDown = math.floor((h * 0.4) + 0.5)
    button.h.active = h

    button.colors = {}
    button.colors.top = {}
    button.colors.top.default = color
    button.colors.top.onMouseOver = {color[1] - 0.15, color[2] - 0.15, color[3] - 0.15}
    button.colors.top.onMouseDown = {color[1] - 0.25, color[2] - 0.25, color[3] - 0.25}
    button.colors.top.active = color
    button.colors.side = {}
    button.colors.side.default = {color[1] - 0.15, color[2] - 0.15, color[3] - 0.15}
    button.colors.side.onMouseOver = {color[1] - 0.3, color[2] - 0.3, color[3] - 0.3}
    button.colors.side.onMouseDown = {color[1] - 0.5, color[2] - 0.5, color[3] - 0.5}
    button.colors.side.active = button.colors.side.default

    button.isClicked = false

    function button.isMouseOver()
        local isMouseOver = false
        local x, y = love.mouse.getPosition()

        for i = 1, button.h.active do
            if (math.pow(x - button.x, 2) / math.pow(button.rx, 2)) +
                (math.pow(y - button.y + i, 2) / math.pow(button.ry, 2)) <= 1 then
                isMouseOver = true
            end
        end

        return isMouseOver
    end

    function button.onMouseEnter()
        button.colors.top.active = button.colors.top.onMouseOver
        button.colors.side.active = button.colors.side.onMouseOver
    end

    function button.onMouseExit()
        if not button.isClicked then
            button.colors.top.active = button.colors.top.default
            button.colors.side.active = button.colors.side.default
            love.audio.pause(music)
        end
    end

    function button.onMouseDown()
        if button.isClicked or button.isMouseOver() then
            button.h.active = button.h.onMouseDown
            button.isClicked = true
            love.audio.play(music)
        end
    end

    function button.onMouseUp()
        button.h.active = button.h.default
        button.isClicked = false
        love.audio.pause(music)
    end

    function button.update()
        if button.isMouseOver() then
            button.onMouseEnter()
        else
            button.onMouseExit()
        end
        if button.isClicked then
            button.colors.top.active = button.colors.top.onMouseDown
            button.colors.side.active = button.colors.side.onMouseDown
        end
    end

    function button.draw()
        -- Draw the base of the button
        love.graphics.setColor(BUTTON_COLORS.DARK_GRAY)
        for i = 1, math.floor(H * 0.05) do
            love.graphics.ellipse("fill", button.x, button.y + i, button.rx * 1.2, button.ry * 1.2)
        end
        love.graphics.setColor(BUTTON_COLORS.GRAY)
        love.graphics.ellipse("fill", button.x, button.y, button.rx * 1.2, button.ry * 1.2)

        -- Draw the side of the button
        love.graphics.setColor(button.colors.side.active)
        for i = 1, button.h.active do
            love.graphics.ellipse("fill", button.x, button.y - i, button.rx, button.ry)
        end

        -- Draw the top of the button
        love.graphics.setColor(button.colors.top.active)
        love.graphics.ellipse("fill", button.x, button.y - (button.h.active + 1), button.rx, button.ry)
    end

    return button
end
