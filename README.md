# CS 7x7

#### Video demo: TODO

#### Description:

IDEA

Making a simple puzzle game with Love2d.

I choose to build a clone of and old Android game called 7x7. This game was retired from the Play Store some time ago but I did like it and was simple enough to be re-created as my final project. Here is a video showing the gameplay of the original game:

Gameplay: https://www.youtube.com/watch?v=Eh5baiga2Ig

GAME ASSETS

- header with score and preview area (next tiles' color)
- 7x7 grid where tiles are placed
- player's cursor (black when picking a tile, red when moving a tile)

GAMEPLAY

The goal is to clear lines of four or more tiles with the same color to score points. Lines can be:

- horizontal
- vertical 
- diagonal (both ways)

After each turn new tiles are places; when the grid is full (no more tiles can be placed) and no line ca be cleared the game ends. Then number of new tiles increase with score (starting with 3, then 4, 5 and 6 at 50, 100 and 150 points). 

PLAYER INTERACTION

The player can move one tile on each turn trying to line four tiles. A tile can be moved only if a clear path exist (empty grid cells). Movement happens via keyboard input:

- arrows to move the cursor
- space bar to pick and place tiles
- esc to abort movement when a tile is picked 
- r restarts the game

TODO

- add animations?
- add leaderboard?
- add combo scores?
- add undo button?
