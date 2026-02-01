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
private GameManager gameManager;

void setup() {
  //create a window
  //Using P2D renderer
  size(1080, 608, P2D);
  //fullscreen(P2D);
  pixelDensity(1);

  // setup current logger
  Logger.setLogDir(savePath(AsteroidConstants.LOGGING_DIR));

  //Turn off Anti-aliasing
  smooth();

  // Init Game Manager
  gameManager = new GameManager(this);

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
  collisionMechanics = new CollisionMechanics(ship, asteroids, this);

  // Init Player Controller
  playerController = new PlayerController();
}

public void draw() {
  gameManager.update();
}

public void mousePressed() {
  gameManager.handleMousePressed();
}

public void syncScore(Integer s) {
  gameManager.setScore(s);
}

public void onPlayerDeath() {
  gameManager.onPlayerDeath();
}

public void onWaveCleared() {
  gameManager.onWaveCleared();
}


// Generic Main APIs (Getters/Setters)
public int getLevel() {
  return gameManager.getLevel();
}

public void setLevel(int level) {
  gameManager.setLevel(level);
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

public ExplosionController getExplosionController() {
  return explosions;
}

public UFOController getUFOController() {
  return ufoController;
}

public void setUFOController(UFOController ufoController) {
  this.ufoController = ufoController;
}

public CollisionMechanics getCollisionMechanics() {
  return collisionMechanics;
}

public void setCollisionMechanics(CollisionMechanics collisionMechanics) {
  this.collisionMechanics = collisionMechanics;
}

public PlayerController getPlayerController() {
  return playerController;
}

public void setPlayerController(PlayerController playerController) {
  this.playerController = playerController;
}

public void keyPressed() {
  playerController.keyPressed();
}

public void keyReleased() {
  playerController.keyReleased();
}

public Integer getScore() {
  return gameManager.getScore();
}

public void setScore(Integer score) {
  gameManager.setScore(score);
}

public int getLives() {
  return gameManager.getLives();
}

public void setLives(int lives) {
  gameManager.setLives(lives);
}

public int getGameTimer() {
  return gameManager.getGameTimer();
}

public void setGameTimer(int gameTimer) {
  gameManager.setGameTimer(gameTimer);
}

// Transition Timer Delegate
public int getTransitionDelayTimer() {
  return gameManager.getTransitionDelayTimer();
}

public void setTransitionDelayTimer(int transitionDelayTimer) {
  gameManager.setTransitionDelayTimer(transitionDelayTimer);
}

public int getLevelCountdownTimer() {
  return gameManager.getLevelCountdownTimer();
}

public void setLevelCountdownTimer(int levelCountdownTimer) {
  gameManager.setLevelCountdownTimer(levelCountdownTimer);
}

public GameManager getGameManager() {
  return gameManager;
}
