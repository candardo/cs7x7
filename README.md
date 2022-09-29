IDEA

Clone of an Android puzzle game called 7x7
Gameplay: https://www.youtube.com/watch?v=Eh5baiga2Ig

GAME AREA MOKUP 

- header: level and score
- row: preview next three tiles
- 7x7 grid

GAMEPLAY

Goal: clear tile rows to get points. Four or more rows (horizontal, vertical or diagonal) of tiles with the same color are cleared.

On each turn new tiles are places until the grid is full and the game ends. The player can move one tile on each turn trying to line four tiles. Movement happens via keyboard input (arrows and space bar to pick and place the tile to be moved). A tile can be moved only if a clear path exist (empty grid cells).

When the game starts the grid is empty and three tiles with a random color are placed in a random position. After the player moves a tile three new tiles are placed.

TODO

- check for lined tile on four possible directions: horizontal, vertical, diagonal (both slopes)
- new tiles overwrite! fix freetiles

REFACTOR

- cursor color in love.draw
- manage keyboard input depending on tilePicked
