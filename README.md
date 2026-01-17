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
