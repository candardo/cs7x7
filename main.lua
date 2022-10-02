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
    getFreeTiles()

    -- Pick the first three random tiles
    nextTiles(3)

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

    -- Set window size
    love.window.setMode(352, 352)
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

-- Get n random tiles from freeTiles with random color
function nextTiles(n)

    -- Color table keys
    local colorKeys = {'r', 'g', 'b', 'y', 'p'}

    for i = 1, n do
        -- Get random index for freeTile and its coordinates
        local freeTileIndex = love.math.random(#freeTiles)
        local randomTileY = freeTiles[freeTileIndex][1]
        local randomTileX = freeTiles[freeTileIndex][2]
        -- Get random color
        local randomColorKey = colorKeys[love.math.random(5)]
        -- Add new random tile to tiles and remove it from freeTiles
        tiles[randomTileY][randomTileX] = randomColorKey
        getFreeTiles()
    end
end


function love.update(dt)
    -- Quit with no warnings if less than 3 tiles
    if (#freeTiles) < 3 then
        print('no more moves!')
        -- love.event.quit()
    end

    -- New tiles when turn is done
    if turnDone == true then
        turnDone = false
        nextTiles(3)
        -- Check if the new tiles form a line to be cleared
        clearLines()
    end
end


-- Clear lines of four or more contiguous tiles of the same colour
function clearLines()

    -- TODO set turnDone to false if a line is cleared

    -- Horizontal scan
    print('checking all rows')
    for y = 1, 7 do

        -- tiles per color in the row
        local line = {r = {}, g = {}, b = {}, y = {}, p = {}}
        for x = 1, 7 do
            local color = tiles[y][x]
            if color ~= '_' then
                table.insert(line[color], x)
            end
        end

        -- check if four or more tiles of the same color
        for k, v in pairs(line) do
            if #v > 0 then
                print('in row ' .. y .. ' there are ' .. #v .. ' tiles of color ' .. k)
            end
            if #v > 3 then
                print('four or more tiles of the same color')
                local first = v[1]
                local last = v[1]
                for i = 2, (#v) do
                    if v[i] == (first + i - 1) then
                        last = v[i]
                        if last - first > 2 then
                            print('four ' .. k .. ' tiles lined from ' .. first .. ' to ' .. last)
                            for dx = first, last do
                                print('clear tile at y ' .. y .. ' x ' .. dx)
                                tiles[y][dx] = '_'
                            end
                        end
                    else
                        first = v[i]
                        last = v[i]
                    end
                end
            end
        end
    end
end


function love.keypressed(key)
    -- FIXME 'c' key to get three new tiles
    if key == 'c' then
        nextTiles(3)
    end

    -- Cursor movement when no tile is picked (free movement)
    if tilePicked == false then
        if key == 'left' and cursorX > 1 then
            cursorX = cursorX - 1
        elseif key == 'right' and cursorX < 7 then
            cursorX = cursorX + 1
        elseif key == 'up' and cursorY > 1 then
            cursorY = cursorY - 1
        elseif key == 'down' and cursorY < 7 then
            cursorY = cursorY + 1
        elseif key == 'space' and (tiles[cursorY][cursorX] ~= '_') then
            -- Pick tile, remember coordinates and color then delete tile
            tilePicked = true
            pickedTileX = cursorX
            pickedTileY = cursorY
            pickedTileColor = tiles[cursorY][cursorX]
            tiles[cursorY][cursorX] = '_'
        end

    -- Cursor movement when a tile is picked (empty tiles only)
    else
        if key == 'left' and cursorX > 1 and tiles[cursorY][cursorX - 1] == '_' then
            cursorX = cursorX - 1
        elseif key == 'right' and cursorX < 7 and tiles[cursorY][cursorX + 1] == '_' then
            cursorX = cursorX + 1
        elseif key == 'up' and cursorY > 1 and tiles[cursorY - 1][cursorX] == '_' then
            cursorY = cursorY - 1
        elseif key == 'down' and cursorY < 7 and tiles[cursorY + 1][cursorX] == '_' then
            cursorY = cursorY + 1
        elseif key == 'space' and (tiles[cursorY][cursorX] == '_') then
            -- Release tile, set color on empty tile and update freeTiles
            tilePicked = false
            tiles[cursorY][cursorX] = pickedTileColor
            getFreeTiles()
            -- Turn is done if the tile has moved from its original position
            if (cursorX ~= pickedTileX) or (cursorY ~= pickedTileY) then
                turnDone = true
                -- Check for lines to be cleared
                clearLines()
            end
        elseif key == 'escape' then
            -- Abort movement: restore color and get cursor back to picked tile position
            tiles[pickedTileY][pickedTileX] = pickedTileColor
            cursorX = pickedTileX
            cursorY = pickedTileY
            tilePicked = false
            -- TODO Do something (animation?)
            -- print('tile got back to its place')
        end
    end

end


function love.draw()

    -- Draw white grid
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', 0, 0, 2 + 50 * 7, 2 + 50 * 7)

    -- Draw tiles
    for y = 1, 7 do
        for x = 1, 7 do
            -- Get tile color and draw a tile
            love.graphics.setColor(colors[tiles[y][x]])
            love.graphics.rectangle('fill', 2 + ((x - 1) * 50), 2 + ((y - 1) * 50), 48, 48)
       end
    end

    -- Draw player's cursor (black when selecting, red when moving a tile)
    if tilePicked then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(0, 0, 0)
    end
    love.graphics.rectangle('line', 1 + ((cursorX -1) * 50), 1 + ((cursorY - 1) * 50), 50, 50)

    -- Draw picked tile inside cursor
    if tilePicked then
        love.graphics.setColor(colors[pickedTileColor])
        love.graphics.rectangle('fill', 2 + ((cursorX -1) * 50), 2 + ((cursorY - 1) * 50), 48, 48)
    end

end
