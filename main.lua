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

    -- Get a table with all empty/free tiles (all tiles at first)
    freeTiles = {}
    getFreeTiles()

    -- Pick the first three random tiles
    nextTiles(3)

    -- Player's cursor 
    cursorX = 4
    cursorY = 4
    cursorColor = {0, 0, 0}

    -- Pick and place tile information
    tilePicked = false
    pickedTileX = 0
    pickedTileY = 0
    pickedTileColor = nil

    -- Turn done when one tile has moved
    turnDone = false
end

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
        -- Get random index for freeTile and random color
        local freeTileIndex = love.math.random(#freeTiles)
        print('random index ' .. freeTileIndex)
        local randomColorKey = colorKeys[love.math.random(5)]
        -- Get random tile coordinates
        local randomTileY = freeTiles[freeTileIndex][1]
        local randomTileX = freeTiles[freeTileIndex][2]
        -- Add new random tile to tiles and remove it from freeTiles
        print('placing tile at x ' .. randomTileX .. ' y ' .. randomTileY .. ' color ' .. randomColorKey)
        tiles[randomTileY][randomTileX] = randomColorKey
        table.remove(freeTiles,freeTileIndex)
    print('free tiles left ' .. #freeTiles)
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
        -- clearLines()
        -- print(#freeTiles)
        turnDone = false
        nextTiles(3)
    end
end


function clearLines()

    -- Different approach
    -- scan trough line and count num of tiles of the same color
    -- if num >4 there is only one possible line
    -- check if tiles are contiguous
    -- if so remove tiles and add tiles to freeTiles
    -- do the same for the other three directions

    -- Horizontal scan (7 lines)
    -- for y = 1, 7 do
    --     for x = 1, 7 do
    --         -- Current tile color, possible line color and numbeer
    --         -- of occurrences
    --         local tileColor = tiles[y][x]
    --         local lineColor = 'x'
    --         local n = 0
    --         -- tile not empty and no occurrencies yet
    --         if tileColor ~= '_' and n == 0 then
    --             -- firstTileX = x
    --             -- firstTileY = y
    --             lineColor = tileColor
    --             n = 1
    --         -- tile not empty and one or more occurrencies
    --         elseif tileColor ~= '_' and n ~= 0 then
    --             -- same color
    --             if tileColor == lineColor then
    --                 n = n + 1
    --             -- different color, reset n and possible color
    --             else
    --                 lineColor = tileColor
    --                 n = 0
    --             end
    --         -- tile empty, reset n and possibile color
    --         else
    --             n = 0
    --             lineColor = 'x'
    --         end
    --         print(lineColor .. n)
    --     end
    -- end
end


function love.keypressed(key)
    -- TEMP 'c' key to get three new tiles
    if key == 'c' then
        nextTiles(3)
    end

    -- Cursor movement when no tile is picked (free movement)
    if key == 'left' and cursorX > 1 then
        if tilePicked == false then
            cursorX = cursorX - 1
        else
            -- When a tile is picked move on free tiles only
            if tiles[cursorY][cursorX - 1] == '_' then
                cursorX = cursorX - 1
            end
        end
    elseif key == 'right' and cursorX < 7 then
        if tilePicked == false then
            cursorX = cursorX + 1
        else
            if tiles[cursorY][cursorX + 1] == '_' then
                cursorX = cursorX + 1
            end
        end
    elseif key == 'up' and cursorY > 1 then
        if tilePicked == false then
            cursorY = cursorY - 1
        else
            if tiles[cursorY - 1][cursorX] == '_' then
                cursorY = cursorY - 1
            end
        end
    elseif key == 'down' and cursorY < 7 then
        if tilePicked == false then
            cursorY = cursorY + 1
        else
            if tiles[cursorY + 1][cursorX] == '_' then
                cursorY = cursorY + 1
            end
        end
    end

    -- Tile pick and place
    if (key == 'space') then
        -- Picke and move tile
        if (tilePicked == false) and (tiles[cursorY][cursorX] ~= '_') then
            tilePicked = true
            -- Remeber picked tile coordinates and color
            pickedTileX = cursorX
            pickedTileY = cursorY
            pickedTileColor = tiles[cursorY][cursorX]
            -- Delete tile and change cursor color ti signal a picked tile
            tiles[cursorY][cursorX] = '_'
            cursorColor = {1, 0, 0}
        -- Released the picked tile
        elseif (tilePicked == true) and (tiles[cursorY][cursorX] == '_') then
            tilePicked = false
            -- Fix tiles and freeTiles
            tiles[cursorY][cursorX] = pickedTileColor
            -- TODO doesn't remove this tile from freeTiles!
            -- table.insert(freeTiles, {pickedTileY, pickedTileX})
            getFreeTiles()
            cursorColor = {0, 0, 0}
            -- If the tile has moved from its original position the turn is done
            if (cursorX == pickedTileX) and (cursorY == pickedTileY) then
                print('tile got back to its place')
            else
                turnDone = true
            end
        end
    end
    -- Esc key aborts movement
    if key == 'escape' and tilePicked == true then
        tiles[pickedTileY][pickedTileX] = pickedTileColor
        cursorX = pickedTileX
        cursorY = pickedTileY
        tilePicked = false
        cursorColor = {0, 0, 0}
        print('tile got back to its place')
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

    -- Draw player's cursor (black outline)
    love.graphics.setColor(cursorColor)
    love.graphics.rectangle('line', 1 + ((cursorX -1) * 50), 1 + ((cursorY - 1) * 50), 50, 50)
    if tilePicked then
        love.graphics.setColor(colors[pickedTileColor])
        love.graphics.rectangle('fill', 2 + ((cursorX -1) * 50), 2 + ((cursorY - 1) * 50), 48, 48)
    end

end
