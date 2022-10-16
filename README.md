# CS 7x7

#### Video demo: https://www.youtube.com/watch?v=stG-lBVQnGA

#### Description: puzzle game made with the LÖVE framework

## IDEA

Making a simple puzzle game with Love2d.

I choose to build a clone of and old Android game called 7x7. This game was retired from the Play Store some time ago but I did like it and it was simple enough to be re-created with lua and LÖVE as my final project. 

[Here is a video](Gameplay: https://www.youtube.com/watch?v=Eh5baiga2Ig) showing the gameplay of the original game.

## GAME AREA

- header with score and preview area (next tiles' color)
- 7x7 grid where tiles are placed
- player's cursor (black when picking a tile, red when moving a tile)

## GAMEPLAY

The goal is to clear lines of four or more tiles with the same color to score points. Line direction can be:

- horizontal
- vertical 
- diagonal (both ways)

After each turn new tiles are places. When the grid is full (no more tiles can be placed) and no line ca be cleared the game ends. Then number of new tiles increase with score, starting with 3, then 4, 5 and 6 at 50, 100 and 150 points. 

## PLAYER INTERACTION

The player can move one tile on each turn trying to line four tiles. A tile can be moved only if a clear path exist (empty grid marked with gray color). Movement happens via keyboard input:

- arrows to move the cursor
- space bar to pick and place tiles
- esc to abort movement when a tile is picked 
- r restarts the game

## DESIGN CHOICES

- no libraries, write everything myself
- learn using tools like git, neovim
- build a prototype as fast as possible

## WHAT'S IN THE DIRECTORY OF THE PROJECT

- a small config file to set icon and window title
- the main.lua file with the full game code
- some picture used for the splash screens
- a font file
- a few sounds

## THE MAIN.LUA FILE

Other than the usual love2d functions I wrote a few custom ones:

- getFreeTiles() updates a table with free tiles coordinates
- pickColors() picks n random colors for the next tiles to be placed
- nextTiles() places new random tiles matching colors to random coordinates of free tiles
- fourConsecutive() returns a a table with four consecutive numbers of x or y coordinates of a line if any, so that a line can be cleared
- clearLines() checks for possible lines of four or more tiles of the same color in every direction and clears them
love.keypressed() manages player interaction

## TODO

- add animations?
- add leaderboard?
- add combo scores?
- add undo button?
- rewrite using some library, maybe [HUMP](https://love2d.org/wiki/HUMP)
- learn how to debug lua/love2d code
