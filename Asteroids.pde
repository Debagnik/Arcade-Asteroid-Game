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
private TitleScreen titleScreen;
private AsteroidConstants.GameState gameState = AsteroidConstants.INITIAL_GAME_STATE; //game Starts with the title screen
private int level = AsteroidConstants.INITIAL_LEVEL;
private int respawnTimer = 0;

private Integer score = 0;
private int lives = 0;
private int gameTimer = 0; // In Frames

// Transition Timer Variables
private int transitionDelayTimer = 0;
private int levelCountdownTimer = 0;

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

  //Init Title Screen
  titleScreen = new TitleScreen(this);

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
  if (gameState != AsteroidConstants.GameState.LEVEL_TRANSITION) {
      background(20, 20, 30);
  }

  if(gameState == AsteroidConstants.GameState.PLAYING){
    runGame();
  } else if (gameState == AsteroidConstants.GameState.LEVEL_TRANSITION) {
    runLevelTransition();
  } else {
    titleScreen.display(gameState, asteroids);
  }

}

public void mousePressed() {
  if (gameState != AsteroidConstants.GameState.PLAYING && gameState != AsteroidConstants.GameState.LEVEL_TRANSITION) {
      AsteroidConstants.GameState newState = titleScreen.handleTitleScreenClick(gameState);
      
      if (newState == AsteroidConstants.GameState.PLAYING && gameState != AsteroidConstants.GameState.PLAYING) {
          resetGame();
      }
      gameState = newState;
  }
}

private void runGame(){
  if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.TIME_BOUND) {
      gameTimer--;
      if (gameTimer <= 0) {
          gameState = AsteroidConstants.GameState.MENU_MAIN;
          return;
      }
  }

  if (respawnTimer > 0) {
    playerController.activateRespawnMechanics();
  } else {
    activeGameplayHandler();
  }
}

private void runLevelTransition() {
    if (transitionDelayTimer > 0) {
        transitionDelayTimer--;
        background(20, 20, 30); 
        activeGameplayHandler();
        
        if (transitionDelayTimer <= 0) {
            levelCountdownTimer = 5 * 60; // 5 seconds
        }
        return;
    }

    background(0);
    textAlign(CENTER, CENTER);
    fill(255);
    textSize(40);
    text("LEVEL " + getLevel() + " CLEARED", width/2, height/2 - 50);
    
    textSize(60);
    int secondsLeft = ceil(levelCountdownTimer / 60.0f);
    text(secondsLeft, width/2, height/2 + 20);

    levelCountdownTimer--;
    
    if (levelCountdownTimer <= 0) {
        startNextWave();
        gameState = AsteroidConstants.GameState.PLAYING;
        // Unlock controls (Assuming PlayerController has setEnableControls added)
        playerController.setEnableControls(true);
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

private void resetGame() {
    score = 0;
    respawnTimer = 0;

    if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.TIME_BOUND) {
      level = AsteroidConstants.INITIAL_LEVEL_TIME_BOUND;
      int seconds = AsteroidConstants.GAME_MODE_SETTINGS.get(AsteroidConstants.GameModeEnum.TIME_BOUND);
      gameTimer = seconds * 60;
      lives = AsteroidConstants.INFINITE_LIVES; //Infinite Lives (Not actually, just a very large number)
    } else {
      level = AsteroidConstants.INITIAL_LEVEL;
      lives = AsteroidConstants.GAME_MODE_SETTINGS.get(AsteroidConstants.GAME_MODE);
    }
    ship = new Spacecraft();
    asteroids.clear();
    int count = PhysicsHelper.getAsteroidsCountBasedOnCurrentLevel(level);
    //Logger.log(count, level);
    for (int i = 0; i < count; i++) {
        asteroids.add(new Asteroid(ship, AsteroidConstants.ASTEROID_SHIP_SAFE_DISTANCE));
    }
    respawnTimer = 0;
    weapon = new WeaponsController();
    explosions.reset();
    ufoController = new UFOController(explosions);
    collisionMechanics = new CollisionMechanics(ship, asteroids, this);
    playerController = new PlayerController();
}

public void syncScore(Integer s) {
    setScore(s);
}

public void onPlayerDeath() {
    if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.ENDLESS) {
        gameState = AsteroidConstants.GameState.MENU_MAIN;
    }
    else if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.CLASSIC) {
        lives--;
        if (lives <= 0) {
            gameState = AsteroidConstants.GameState.MENU_MAIN;
        }
    }
}

public void onWaveCleared() {
  
  // CollisionMechanics runs during the transition delay. 
  // If we are already transitioning, ignore repeated calls.
  if (gameState == AsteroidConstants.GameState.LEVEL_TRANSITION) {
      return;
  }

  if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.CLASSIC) {
        gameState = AsteroidConstants.GameState.LEVEL_TRANSITION;
        transitionDelayTimer = 6; // ~100ms at 60fps
        
        playerController.setEnableControls(false);
        for(UFO u : ufoController.getActiveUFOs()){
             explosions.animateUFOExplosion(u);
        }
        ufoController.setActiveUFOs(new ArrayList<UFO>());
    } else {
        startNextWave();
    }
}

private void startNextWave() {
    level++;
    asteroids.clear();
    int count = PhysicsHelper.getAsteroidsCountBasedOnCurrentLevel(level);
    for (int i = 0; i < count; i++) {
        asteroids.add(new Asteroid(ship, AsteroidConstants.ASTEROID_SHIP_SAFE_DISTANCE));
    }
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

public Integer getScore() {
    return score;
}

public void setScore(Integer score) {
    this.score = Math.max(0, score);
}

public int getLives() {
    return lives;
}

public void setLives(int lives) {
    this.lives = Math.max(0, lives);
}

public int getGameTimer() {
    return gameTimer;
}

public void setGameTimer(int gameTimer) {
    this.gameTimer = gameTimer;
}

// Transition Timer

public int getTransitionDelayTimer() {
    return transitionDelayTimer;
}

public void setTransitionDelayTimer(int transitionDelayTimer) {
    this.transitionDelayTimer = transitionDelayTimer;
}

public int getLevelCountdownTimer() {
    return levelCountdownTimer;
}

public void setLevelCountdownTimer(int levelCountdownTimer) {
    this.levelCountdownTimer = levelCountdownTimer;
}


