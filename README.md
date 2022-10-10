IDEA

Clone of an Android puzzle game called 7x7
Gameplay: https://www.youtube.com/watch?v=Eh5baiga2Ig

GAME AREA

- header: score and next colors coming up
- 7x7 grid
- player's cursor (black when picking a tile, red when moving a tile)

GAMEPLAY

Goal: clear lines of four or more tiles with the same color to score points. Lines can be:

- horizontal
- vertical 
- diagonal (both ways)

On each turn new tiles are places until the grid is full and the game ends. Then number of new tiles increase with score (starting with 3, then 4, 5 and 6 at 50, 100 and 150 points). 

The player can move one tile on each turn trying to line four tiles. A tile can be moved only if a clear path exist (empty grid cells). Movement happens via keyboard input:

- arrows to move the cursor
- space bar to pick and place tiles
- esc to abort movement when a tile is picked 
- r restarts the game

TODO

- add animations?
- add leaderboard?
- add combo scores?
