## basel_level.tscn

- Background: well, the background
- AtHUD (scene = timer): shows timer on top right corner in the HUD canvas layer
- Unpauses: when this scene is ready, the game will be unpaused
- StateGame: when this scene is ready, the game state is set to "game"
- Pauseable: accepts P/Start/Esc to pause the game and show the pause screen
- Checkpoint (active = true, spawn on ready = true): spawns the player on ready, also when pressing R/Select
- LevelGoal (scene = next level): world boundary, when the player reaches it, it goes to the next level
