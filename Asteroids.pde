/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Asteroids.pde
 */

import java.util.HashSet;

// Main Game File
// Define Global Variables
private ArrayList<Asteroid> asteroids; //adds a list of asteriods
private Spacecraft ship; //Adds a player ship
private WeaponsController weapon;
private ExplosionController explosions;  //Explosion Particle controller
private UFOController ufoController;
private CollisionMechanics collisionMechanics;
private PlayerController playerController;
private int level = 1; // Never Set it 0 (Non-Zero value)
private int respawnTimer = 0;

void setup() {
  //create a window
  //Using P2D renderer
  size(1080, 608, P2D);
  pixelDensity(1);

  // setup current logger
  Logger.setLogDir(savePath(AsteroidConstants.LOGGING_DIR));

  //Turn off Anti-aliasing
  smooth();

  //Init the player ship
  ship = new Spacecraft();

  //Init Asteroids List
  asteroids = new ArrayList<Asteroid>();
  //create INITIAL_ASTEROID_COUNT asteroids to start game.
  for (int i = 0; i < AsteroidConstants.INITIAL_ASTEROID_COUNT; i++) {
    asteroids.add(new Asteroid(ship, AsteroidConstants.ASTEROID_SHIP_SAFE_DISTANCE));
  }
  // Init Weapons controller
  weapon = new WeaponsController();

  //Init Explosion Controller
  explosions = new ExplosionController();

  // Init ufo controller
  ufoController = new UFOController(explosions);

  // Init Collision Mechanics
  collisionMechanics = new CollisionMechanics();

  // Init Player Controller
  playerController = new PlayerController();
}

void draw() {
  //Set BG to a a dark color with RGB values
  background(20, 20, 30);

  if (respawnTimer > 0) {
    playerController.activateRespawnMechanics();
  } else {
    activeGameplayHandler();
  }
}

private void activeGameplayHandler() {
  playerController.shipMechanics();
  // Weapons Handling
  weapon.displayAndUpdate();
  //Explosion handling
  explosions.displayAndUpdate();
  //UFO Mechanics
  ufoController.update(getLevel(), asteroids, weapon.getPlayerLasers());
  //Asteroid mechanics
  collisionMechanics.asteroidsMechanics();
  //UFO Hits mechanism
  collisionMechanics.checkUFOAttacksOnPlayer();
  //player collision mechanics
  collisionMechanics.checkPlayerCollision();
}


// Generic Main APIs (Getters/Setters)
public int getLevel() {
  return level;
}

public void setLevel(int level) {
  this.level = level;
}

public ArrayList<Asteroid> getAsteroids() {
  return asteroids;
}

public void setAsteroids(ArrayList<Asteroid> asteroids) {
  this.asteroids = asteroids;
}

public Spacecraft getShip() {
  return ship;
}

public void setShip(Spacecraft ship) {
  this.ship = ship;
}

public WeaponsController getWeapon() {
  return weapon;
}

public void setWeapon(WeaponsController weapon) {
  this.weapon = weapon;
}

public void keyPressed() {
  playerController.keyPressed();
}

public void keyReleased() {
  playerController.keyReleased();
}

