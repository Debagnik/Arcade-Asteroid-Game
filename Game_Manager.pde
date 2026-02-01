/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2026 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Game_Manager.pde
 */

import java.util.ArrayList;

public class GameManager {
  private Asteroids parent;

  // Game Elements managed by GameManager (or referenced)
  private TitleScreen titleScreen;

  // Game State Variables
  private AsteroidConstants.GameState gameState = AsteroidConstants.INITIAL_GAME_STATE;
  private int level = AsteroidConstants.INITIAL_LEVEL;
  private int respawnTimer = 0;
  private Integer score = 0;
  private int lives = 0;
  private int gameTimer = 0; // In Frames

  // Transition Timer Variables
  private int transitionDelayTimer = 0;
  private int levelCountdownTimer = 0;

  public GameManager(Asteroids parent) {
    this.parent = parent;
    this.titleScreen = new TitleScreen(parent);
  }

  public void update() {
    if (gameState != AsteroidConstants.GameState.LEVEL_TRANSITION) {
      parent.background(20, 20, 30);
    }

    if (gameState == AsteroidConstants.GameState.PLAYING) {
      runGame();
    } else if (gameState == AsteroidConstants.GameState.LEVEL_TRANSITION) {
      runLevelTransition();
    } else {
      titleScreen.display(gameState, parent.getAsteroids());
    }
  }

  public void handleMousePressed() {
    if (gameState != AsteroidConstants.GameState.PLAYING && gameState != AsteroidConstants.GameState.LEVEL_TRANSITION) {
      AsteroidConstants.GameState newState = titleScreen.handleTitleScreenClick(gameState);

      if (newState == AsteroidConstants.GameState.PLAYING && gameState != AsteroidConstants.GameState.PLAYING) {
        resetGame();
      }
      gameState = newState;
    }
  }

  private void runGame() {
    if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.TIME_BOUND) {
      gameTimer--;
      if (gameTimer <= 0) {
        gameState = AsteroidConstants.GameState.MENU_MAIN;
        return;
      }
    }



    if (respawnTimer > 0) {
      parent.getPlayerController().activateRespawnMechanics();
    } else {
      activeGameplayHandler();
    }
  }

  private void runLevelTransition() {
    if (transitionDelayTimer > 0) {
      transitionDelayTimer--;
      parent.background(20, 20, 30);
      activeGameplayHandler();

      if (transitionDelayTimer <= 0) {
        levelCountdownTimer = 5 * 60; // 5 seconds
      }
      return;
    }

    parent.background(0);
    parent.textAlign(PConstants.CENTER, PConstants.CENTER); // PConstants for static access
    parent.fill(255);
    parent.textSize(40);
    parent.text("LEVEL " + level + " CLEARED", parent.width / 2, parent.height / 2 - 50);

    parent.textSize(60);
    int secondsLeft = PApplet.ceil(levelCountdownTimer / 60.0f);
    parent.text(secondsLeft, parent.width / 2, parent.height / 2 + 20);

    levelCountdownTimer--;

    if (levelCountdownTimer <= 0) {
      startNextWave();
      gameState = AsteroidConstants.GameState.PLAYING;
      // Unlock controls
      parent.getPlayerController().setEnableControls(true);
    }
  }

  private void activeGameplayHandler() {
    parent.getPlayerController().shipMechanics();
    // Helpers for readability
    WeaponsController weapon = parent.getWeapon();
    ExplosionController explosions = parent.getExplosionController();
    UFOController ufoController = parent.getUFOController();
    CollisionMechanics collisionMechanics = parent.getCollisionMechanics();

    // Weapons Handling
    weapon.displayAndUpdate();
    // Explosion handling
    explosions.displayAndUpdate();
    // UFO Mechanics
    ufoController.update(level, parent.getAsteroids(), weapon.getPlayerLasers());
    // Asteroid mechanics
    collisionMechanics.asteroidsMechanics();
    // UFO Hits mechanism
    collisionMechanics.checkUFOAttacksOnPlayer();
    // player collision mechanics
    collisionMechanics.checkPlayerCollision();
  }

  public void resetGame() {
    score = 0;
    respawnTimer = 0; // Note: this field is locally tracked now

    if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.TIME_BOUND) {
      level = AsteroidConstants.INITIAL_LEVEL_TIME_BOUND;
      int seconds = AsteroidConstants.GAME_MODE_SETTINGS.get(AsteroidConstants.GameModeEnum.TIME_BOUND);
      gameTimer = seconds * 60;
      lives = AsteroidConstants.INFINITE_LIVES;
    } else {
      level = AsteroidConstants.INITIAL_LEVEL;
      lives = AsteroidConstants.GAME_MODE_SETTINGS.get(AsteroidConstants.GAME_MODE);
    }

    // Reset Parent Objects
    parent.setShip(new Spacecraft());
    parent.getAsteroids().clear();
    int count = PhysicsHelper.getAsteroidsCountBasedOnCurrentLevel(level);
    for (int i = 0; i < count; i++) {
      parent.getAsteroids().add(new Asteroid(parent.getShip(), AsteroidConstants.ASTEROID_SHIP_SAFE_DISTANCE));
    }

    respawnTimer = 0;
    parent.setWeapon(new WeaponsController());
    parent.getExplosionController().reset();
    parent.setUFOController(new UFOController(parent.getExplosionController()));
    parent.setCollisionMechanics(new CollisionMechanics(parent.getShip(), parent.getAsteroids(), parent));
    parent.setPlayerController(new PlayerController());
  }

  public void startNextWave() {
    level++;
    parent.getAsteroids().clear();
    int count = PhysicsHelper.getAsteroidsCountBasedOnCurrentLevel(level);
    for (int i = 0; i < count; i++) {
      parent.getAsteroids().add(new Asteroid(parent.getShip(), AsteroidConstants.ASTEROID_SHIP_SAFE_DISTANCE));
    }
  }

  public void onPlayerDeath() {
    if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.ENDLESS) {
      gameState = AsteroidConstants.GameState.MENU_MAIN;
    } else if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.CLASSIC) {
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

      parent.getPlayerController().setEnableControls(false);
      for (UFO u : parent.getUFOController().getActiveUFOs()) {
        parent.getExplosionController().animateUFOExplosion(u);
      }
      parent.getUFOController().setActiveUFOs(new ArrayList<UFO>());
    } else {
      startNextWave();
    }
  }

  // Getters and Setters
  public AsteroidConstants.GameState getGameState() {
    return gameState;
  }

  public void setGameState(AsteroidConstants.GameState gameState) {
    this.gameState = gameState;
  }

  public int getLevel() {
    return level;
  }

  public void setLevel(int level) {
    this.level = level;
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

  public int getRespawnTimer() {
    return respawnTimer;
  }

  public void setRespawnTimer(int respawnTimer) {
    this.respawnTimer = respawnTimer;
  }

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
}
