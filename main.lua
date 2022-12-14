function love.load()
    -- tile colors
    colors = {
        ['_'] = {.9, .9, .9},
        r = {0.992, 0.184, 0.09},
        g = {0.553, 0.761, 0.008},
        b = {0, 0.663, 0.996},
        y = {1, .733, 0.008},
        p = {.71, .314, .918}
    }

    -- 7x7 game area (49 tiles) initally empty ('_' char)
    tiles = {}
    for y = 1, 7 do
        tiles[y] = {}
        for x = 1, 7 do
            tiles[y][x] = '_'
        end
    end

    -- Get a table with all free tiles coordinates
    freeTiles = {}
    -- Each time getFreeTiles() is called freeTiles is refreshed
    getFreeTiles()

    -- Score and level (start with 3 new tiles each turn, then more)
    score = 0
    level = 3

    -- Pick random colors
    -- pickColors() fills nextColors with #level random colors
    nextColors = {}
    pickColors(level)

    -- Add color to next tiles
    -- then pick new colors again (do be displayed on top header)
    nextTiles(#nextColors)  
    pickColors(level)

    -- Player's cursor 
    cursorX = 4
    cursorY = 4

    -- Pick and place tile information
    tilePicked = false
    pickedTileX = 0
    pickedTileY = 0
    pickedTileColor = nil

    -- Turn done when one tile has moved
    turnDone = false

    -- Game over
    gameOver = false

    -- Splash screen on startup
    splash = true

    -- Delay after new tiles are placed (.2 secs)
    delay = 0

    -- Set window size (move it to love.conf?)
    love.window.setMode(352, 452)

    -- Sounds
    sfxMove = love.audio.newSource("move.ogg", "static")
    sfxClear = love.audio.newSource("clear.ogg", "static")
    sfxPicked = love.audio.newSource("picked.ogg", "static")
    sfxAbort = love.audio.newSource("abort.ogg", "static")

    -- Font
    scoreFont = love.graphics.newFont("K26ToyBlocks123.ttf", 30)

    -- Splash and game over images
    splashImg = love.graphics.newImage('splash.png')
    gameOverImg = love.graphics.newImage('gameover.png')

    -- Keyboard repeat (useful for cursor movements)
    love.keyboard.setKeyRepeat(true)

end


-- Refresh freeTiles table with free tiles coordinates
function getFreeTiles()
    freeTiles = {}
    for y = 1, 7 do
         for x = 1, 7 do
             if tiles[y][x] == '_' then
                 table.insert(freeTiles, {y, x})
             end
         end
     end
end


-- Pick n random colors, called with level as argument
function pickColors(n)

    -- Clear previous colors
    nextColors = {}

    -- Color table keys
    local colorKeys = {'r', 'g', 'b', 'y', 'p'}
    for i = 1, n do
        -- Get random color
        local randomColorKey = colorKeys[love.math.random(5)]
        table.insert(nextColors, randomColorKey)
    end
end


-- Get n random tiles from freeTiles and add color
-- called with #nextColors as argument (same as level)
function nextTiles(n)

    -- Get random free tile and add color
    for i = 1, n do
        -- Get random index for freeTile and its coordinates
        local freeTileIndex = love.math.random(#freeTiles)
        local randomTileY = freeTiles[freeTileIndex][1]
        local randomTileX = freeTiles[freeTileIndex][2]
        -- Add color from nextColors
        tiles[randomTileY][randomTileX] = nextColors[i]
        -- One free tile less so update freeTiles
        getFreeTiles()
    end
end


-- TODO delete debug functions
function printFreeTiles()
    print('free tiles ' .. #freeTiles)
    for i, v in ipairs(freeTiles) do
        print(i .. '\ttile at x ' .. v[2] .. ' y ' .. v[1])
    end
end
function printBoard()
    for y = 1, 7 do
        row = ''
        for x = 1, 7 do
            row = row .. tiles[y][x]
        end
        print(row)
    end
end


function love.update(dt)

    -- Game over
    if (turnDone == true and #freeTiles < level) or #freeTiles == 0 then
        gameOver = true
        -- Stop game
        turnDone = false
    end

    -- New tiles when turn is done
    if turnDone == true then
        turnDone = false
        -- Bump up level
        if score > 150 then
            level = 6
        elseif score > 100 then
            level = 5
        elseif score > 50 then
            level = 4
        end
        -- Place new tiles
        nextTiles(#nextColors)
        printFreeTiles()
        printBoard()
        -- Ugly delay to show new tiles before they're cleared 
        love.timer.sleep(.4)
        -- Check if the new tiles form a line to be cleared
        clearLines()
        -- Get new colors to display
        pickColors(level)
        -- delay = delay + dt
        -- if delay > 2 then
        --     delay = 0
        --     printFreeTiles()
        --     printBoard()
        --     -- Check if the new tiles form a line to be cleared
        --     clearLines()
        --     -- Get new colors to display
        --     pickColors(level)
        -- end
    end
end


-- Returns a table with the position of four or more consecutive colors 
-- list is a table where key = color, value = table of its positions
function fourConsecutive(list)

    -- Return a table with four or more consecutive numbers
    local subset = {}

    -- Check each color for four or more elements
    for k, v in pairs(list) do
        -- Four tiles of the same color (once per list)
        if #v > 3 then
            -- Try starting with the first element of that color
            local first = v[1]
            local last = v[1]
            for i = 2, (#v) do
                -- Adjust last if current element is consecutive to the first
                if v[i] == (last + 1) then
                    last = v[i]
                -- Not consecutive
                else
                    -- Break if already found four or more consecutive elements
                    if last - first > 2 then
                        break
                    -- Try again starting with the current element
                    else
                        first = v[i]
                        last = v[i]
                    end
                end
            end
            -- Return the subset of at least four consecutive numbers 
            if last - first > 2 then
                for i = first, last do
                    table.insert(subset, i)
                end
                return subset
            end
            break
        end
    end
    -- Return empty table
    return subset
end


-- Clear lines of four or more contiguous tiles of the same colour
function clearLines()

    -- Horizontal scan
    for y = 1, 7 do

        -- tiles per color in the row
        local line = {r = {}, g = {}, b = {}, y = {}, p = {}}
        for x = 1, 7 do
            local color = tiles[y][x]
            if color ~= '_' then
                table.insert(line[color], x)
            end
        end
        match = fourConsecutive(line)
        if #match > 0 then
            sfxClear:play()
            score = score + #match
            for i,v in ipairs(match) do
                tiles[y][v] = '_'
                turnDone = false
            end
        end
    end

    -- Vertical scan
    for x = 1, 7 do

        -- tiles per color in the row
        local line = {r = {}, g = {}, b = {}, y = {}, p = {}}
        for y = 1, 7 do
            local color = tiles[y][x]
            if color ~= '_' then
                table.insert(line[color], y)
            end
        end
        match = fourConsecutive(line)
        if #match > 0 then
            sfxClear:play()
            score = score + #match
            for i,v in ipairs(match) do
                tiles[v][x] = '_'
                turnDone = false
            end
        end
    end

    -- Diagonal top-left bottom-right scan
    for n = -3, 3 do

        -- tiles per color in the diagonal
        local diag = {r = {}, g = {}, b = {}, y = {}, p = {}}
        for y = 1, 7 do
            if (y+n) > 0 and (y+n) < 8 then
                local color = tiles[y][y+n]
                if color ~= '_' then
                    table.insert(diag[color], y+n)
                end
            end
        end
        match = fourConsecutive(diag)
        if #match > 0 then
            sfxClear:play()
            score = score + #match
            for i,v in ipairs(match) do
                tiles[v-n][v] = '_'
                turnDone = false
            end
        end
    end

    -- Diagonal top-right to bottom-left
    for n = 5, 11 do

        -- tiles per color in the diagonal
        local diag = {r = {}, g = {}, b = {}, y = {}, p = {}}
        for y = 1, 7 do
            if (n-y) > 0 and (n-y) < 8 then
                local color = tiles[y][n-y]
                if color ~= '_' then
                    table.insert(diag[color], 1, n-y)
                end
            end
        end
        match = fourConsecutive(diag)
        if #match > 0 then
            sfxClear:play()
            score = score + #match
            for i,v in ipairs(match) do
                tiles[n-v][v] = '_'
                turnDone = false
            end
        end
    end
    getFreeTiles()
end


function love.keypressed(key)

    -- Restart game
    if key == 'r' then
        if splash == true then
            splash = false
            return
        else
            love.event.quit('restart')
        end
    end

    -- No more keyboard interaction on game over
    if gameOver == true then
        return
    end

    -- Cursor movement when no tile is picked (free movement)
    if tilePicked == false then
        if key == 'left' and cursorX > 1 then
            cursorX = cursorX - 1
            sfxMove:play()
        elseif key == 'right' and cursorX < 7 then
            cursorX = cursorX + 1
            sfxMove:play()
        elseif key == 'up' and cursorY > 1 then
            cursorY = cursorY - 1
            sfxMove:play()
        elseif key == 'down' and cursorY < 7 then
            cursorY = cursorY + 1
            sfxMove:play()
        elseif key == 'space' and (tiles[cursorY][cursorX] ~= '_') then
            -- Pick tile, remember coordinates and color then delete tile
            sfxPicked:play()
            tilePicked = true
            pickedTileX = cursorX
            pickedTileY = cursorY
            pickedTileColor = tiles[cursorY][cursorX]
            tiles[cursorY][cursorX] = '_'
        end

    -- Cursor movement when a tile is picked (empty tiles only)
    elseif tilePicked == true then
        if key == 'left' and cursorX > 1 and tiles[cursorY][cursorX - 1] == '_' then
            cursorX = cursorX - 1
            sfxMove:play()
        elseif key == 'right' and cursorX < 7 and tiles[cursorY][cursorX + 1] == '_' then
            cursorX = cursorX + 1
            sfxMove:play()
        elseif key == 'up' and cursorY > 1 and tiles[cursorY - 1][cursorX] == '_' then
            cursorY = cursorY - 1
            sfxMove:play()
        elseif key == 'down' and cursorY < 7 and tiles[cursorY + 1][cursorX] == '_' then
            cursorY = cursorY + 1
            sfxMove:play()
        elseif key == 'space' and (tiles[cursorY][cursorX] == '_') then
            -- Release tile, set color on empty tile and update freeTiles
            sfxPicked:play()
            tilePicked = false
            tiles[cursorY][cursorX] = pickedTileColor
            -- Update freeTiles
            getFreeTiles()
            -- Turn is done if the tile has moved from its original position
            if (cursorX ~= pickedTileX) or (cursorY ~= pickedTileY) then
                -- Tile moved so end turn
                turnDone = true
                -- But first check for lines to be cleared (if any turnDone is set to false)
                clearLines()
            end
        elseif key == 'escape' then
            -- Abort movement: restore color and get cursor back to picked tile position
            sfxAbort:play()
            tiles[cursorY][cursorX] = '_'
            tiles[pickedTileY][pickedTileX] = pickedTileColor
            cursorX = pickedTileX
            cursorY = pickedTileY
            tilePicked = false
        end
    end
end


function love.draw()

    -- Splash screen
    if splash == true then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(splashImg, 6, 6)
        return
    end

    -- Draw white background
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', 0, 0, 2 + 50 * 7, 2 + 50 * 7 + 100)

    -- Print score
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(scoreFont)
    love.graphics.print('Score', 20, 20)
    love.graphics.print(score, 20, 60)

    -- Print next tiles color
    love.graphics.print('next', 200, 20)
    for i = 1, #nextColors do
        love.graphics.setColor(colors[nextColors[i]])
        love.graphics.rectangle('fill', 201 + ((i - 1) * 25), 60, 24, 24)
    end

    -- Draw tiles
    for y = 1, 7 do
        for x = 1, 7 do
            -- Get tile color and draw a tile
            love.graphics.setColor(colors[tiles[y][x]])
            love.graphics.rectangle('fill', 2 + ((x - 1) * 50), 100 + 2 + ((y - 1) * 50), 48, 48)
       end
    end

    -- Game over, skip cursor
    if gameOver == true then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(gameOverImg, 50, 200)
        return
    end

    -- Draw player's cursor (black when selecting, red when moving a tile)
    if tilePicked then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(0, 0, 0)
    end
    love.graphics.rectangle('line', 1 + ((cursorX -1) * 50), 100 + 1 + ((cursorY - 1) * 50), 50, 50)

    -- Draw picked tile inside cursor
    if tilePicked then
        love.graphics.setColor(colors[pickedTileColor])
        love.graphics.rectangle('fill', 2 + ((cursorX -1) * 50), 100 + 2 + ((cursorY - 1) * 50), 48, 48)
    end
end
