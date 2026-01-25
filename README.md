# Asteroids Arcade Game

A modern, physics-based recreation of the classic arcade hit "Asteroids," built using the Processing (Java) environment. This project features authentic arcade mechanics, advanced collision physics, and challenging UFO enemies.

## Features

- **Realistic Physics**: Implements conservation of momentum for asteroid-to-asteroid elastic collisions and Arcade-style screen wrapping.
- **Challenging UFOs**: Two types of UFOs (Big and Small) that track the player, fire lasers, and even attempt suicide runs.
- **Dynamic Leveling System**: Infinite gameplay where the difficulty scales as you clear asteroid waves.
- **Visual Effects**: Custom particle-based explosion system for asteroids, ships, and UFOs.
- **Logging System**: Built-in logging for debugging and performance monitoring.
- **Invincibility Frames**: Temporary protection after respawning to ensure fair gameplay.

## Controls

Take command of your spacecraft with these simple keyboard controls:

| Key | Action |
| :--- | :--- |
| **Up Arrow** | Thrust Forward |
| **Left Arrow** | Rotate Counter-Clockwise |
| **Right Arrow** | Rotate Clockwise |
| **Spacebar** | Fire Lasers |

## Asset Setup

**IMPORTANT**: This is an open-source project, but it requires specific licensed assets that are not included in this repository due to licensing restrictions. You must set them up manually before running the game.

### Directory Structure
Ensure your project directories are set up as follows:

```text
Asteroids/
├── data/
│   └── assets/
│       └── fonts/
│           └── Orbitron.ttf      <-- Required Font
├── assets/
│   └── data/
│       └── credits/
│           └── credits.txt       <-- Required Credits File
```

### Obtaining Assets

#### 1. Orbitron Font
- **Source**: [Google Fonts - Orbitron](https://fonts.google.com/specimen/Orbitron)
- **Instructions**:
  1. Download the font family.
  2. Extract the `.ttf` file.
  3. Rename it to `Orbitron.ttf`.
  4. Place it in `data/assets/fonts/`.

#### 2. Credits File
- **Source**: Custom file.
- **Instructions**:
  1. Create a text file named `credits.txt`.
  2. Add credits content (one entry per line).
  3. Place it in `assets/data/credits/`.

### Troubleshooting
- **"Font not found"**: Check that the file is named exactly `Orbitron.ttf` and is in `data/assets/fonts/`.
- **"Credits File Missing"**: Ensure `credits.txt` exists in `assets/data/credits/`.
- **Game Crashes on Start**: Verify both files are present and readable.

### Quick-Start Checklist
- [ ] Clone the repository
- [ ] Create directory `data/assets/fonts/`
- [ ] Download and place `Orbitron.ttf`
- [ ] Create directory `assets/data/credits/`
- [ ] Create and place `credits.txt`
- [ ] Open `Asteroids.pde` in Processing
- [ ] Run the game

## Installation and Usage

To run this game, you need the [Processing Environment](https://processing.org/download/).

1. **Clone or Download** this repository.
```bash
git clone git@github.com:Debagnik/Arcade-Asteroid-Game.git ./Asteroids
```
2. **Open Processing**.
3. **Open the Asteroids.pde** file from the project directory.
4. **Click the Run button** (Play icon) in the Processing IDE.

## Project Structure

- `Asteroids.pde`: Main game loop, setup, and input handling.
- `Asteroids_Constants.pde`: Global game settings, balancing constants, and enums.
- `Asteroids_PhysicsHelper.pde`: Core physics engine (collisions, wrapping, math).
- `Player_SpaceCraft.pde`: Player ship logic and movement.
- `Asteroid_Object.pde`: Asteroid behavior and splitting logic.
- `UFO_Controller.pde` / `UFO_Object.pde`: Enemy AI and spawning logic.
- `Explosion_Controller.pde` / `DebrisAnimation.pde`: Visual effects and particles.
- `Lasers.pde` / `Weapons_Controller.pde`: Projectile mechanics.
- `Loggers.pde`: Utility for game state logging.

## License

This project is licensed under the **WTFPL (Do What The Fuck You Want To Public License)**. See the `LICENSE.md` file for more details.

---
**Author**: Rak Kingabed <debagnik@debagnik.in>
Copyright (c) 2025
