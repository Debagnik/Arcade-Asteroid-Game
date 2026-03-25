/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2026 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Game_Manager.pde
 */

import java.util.ArrayList;

public class GameManager {
  private static final String GAME_OVER_TEXT = "Game Over";
  private static final String YOUR_SCORE_TEXT = "Your Score: ";
  private static final String HIGHSCORE_TEXT = "Highest Score: ";
  private static final String ENTER_USERNAME_TEXT = "Enter a psuedo name";
  private static final String SAVE_N_RETURN = "Save & Return";

  
  private Asteroids parent;

  // Game Elements managed by GameManager (or referenced)
  private TitleScreen titleScreen;
  private HUD hud; //Hud mechanics

  // Game State Variables
  private AsteroidConstants.GameState gameState = AsteroidConstants.INITIAL_GAME_STATE;
  private int level = AsteroidConstants.INITIAL_LEVEL;
  private int respawnTimer = 0;
  private Integer score = 0;
  private int lives = 0;
  private int gameTimer = 0; // In Frames
  private int sessionFramesPlayed = 0; //in frames

  // Transition Timer Variables
  private int transitionDelayTimer = 0;
  private int levelCountdownTimer = 0;

  //Init GameOver UI Elements and Texts
  private String playerNameInput = "";
  private String currentHighScoreDisplay = "000000000";
  private int cursorIndex = 0;


  public GameManager(Asteroids parent) {
    this.parent = parent;
    this.titleScreen = new TitleScreen(parent);
    this.hud = new HUD(parent);
  }

  public void update() {
    if (gameState != AsteroidConstants.GameState.LEVEL_TRANSITION && gameState != AsteroidConstants.GameState.GAME_OVER) {
      parent.background(20, 20, 30);
    }

    if (gameState == AsteroidConstants.GameState.PLAYING) {
      runGame();
    } else if (gameState == AsteroidConstants.GameState.LEVEL_TRANSITION) {
      runLevelTransition();
    } else if (gameState == AsteroidConstants.GameState.GAME_OVER){
      runGameOverScreen();
    } else {
      titleScreen.display(gameState, parent.getAsteroids());
    }
  }

  public void handleMousePressed() {
    if(gameState == AsteroidConstants.GameState.GAME_OVER) {
      handleGameOverClick();
      return;
    }
    if (gameState != AsteroidConstants.GameState.PLAYING && gameState != AsteroidConstants.GameState.LEVEL_TRANSITION) {
      AsteroidConstants.GameState newState = titleScreen.handleTitleScreenClick(gameState);

      if (newState == AsteroidConstants.GameState.PLAYING && gameState != AsteroidConstants.GameState.PLAYING) {
        resetGame();
      }
      gameState = newState;
    }
  }

  private void runGame() {
    sessionFramesPlayed++;
    if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.TIME_BOUND) {
      gameTimer--;
      hud.displayTimeBound(score, gameTimer);
      if (gameTimer <= 0) {
        transitionToGameOver();
        return;
      }
    } else if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.CLASSIC) {
      hud.displayClassic(score, lives, level, parent.getShip().getHP());
    } else if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.ENDLESS) {
      hud.displayEndless(score, level, parent.getShip().getHP());
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
    sessionFramesPlayed = 0;
    respawnTimer = 0; // Note: this field is locally tracked now

    playerNameInput = ""; //reset player name during reset

    if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.TIME_BOUND) {
      level = AsteroidConstants.INITIAL_LEVEL_TIME_BOUND;
      int seconds = AsteroidConstants.GAME_MODE_SETTINGS.get(AsteroidConstants.GameModeEnum.TIME_BOUND);
      gameTimer = seconds * 60; //for 60 frames per second. not a magic number
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
    parent.setCollisionMechanics(new CollisionMechanics(parent.getShip(), parent.getAsteroids(), parent));
    parent.setUFOController(new UFOController(parent.getExplosionController(), parent.getCollisionMechanics()));
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
      transitionToGameOver();
    } else if (AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.CLASSIC) {
      lives--;
      if (lives <= 0) {
        transitionToGameOver();
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
      parent.getShip().setHP(100); // The hull integrity should reset after each level.
      for (UFO u : parent.getUFOController().getActiveUFOs()) {
        parent.getExplosionController().animateUFOExplosion(u);
      }
      parent.getUFOController().setActiveUFOs(new ArrayList<UFO>());
    } else {
      startNextWave();
    }
  }

  private void runGameOverScreen(){
    parent.background(0);
    parent.textAlign(PConstants.CENTER, PConstants.CENTER);

    parent.fill(255,255,255);
    parent.textSize(60);
    parent.text(GAME_OVER_TEXT, parent.width / 2, parent.height / 2 - 150);
    String currentScore = PApplet.nf((int) score, 9);

    parent.fill(255);
    parent.textSize(30);
    parent.text(YOUR_SCORE_TEXT + currentScore, parent.width / 2, parent.height / 2 - 80);
    parent.text(HIGHSCORE_TEXT + currentHighScoreDisplay, parent.width / 2, parent.height / 2 - 40);

    parent.fill(255);
    parent.textSize(20);
    parent.text(ENTER_USERNAME_TEXT, parent.width / 2, parent.height / 2 + 10);

    //Constructing Text Box for name entry
    parent.text(playerNameInput, parent.width / 2, parent.height / 2 + 48);
    if (parent.frameCount % 60 < 30) {
        float totalTextWidth = parent.textWidth(playerNameInput);
        
        // Calculate the exact starting X coordinate of the centered string
        float startX = (parent.width / 2) - (totalTextWidth / 2);
        
        // Calculate the width of the string up to where the cursor is currently positioned
        float cursorOffsetX = parent.textWidth(playerNameInput.substring(0, cursorIndex));
        
        parent.stroke(255);
        // Draw a solid vertical line right where the cursor should be
        parent.line(startX + cursorOffsetX, parent.height / 2 + 35, startX + cursorOffsetX, parent.height / 2 + 61);
    }



    // Save & Return Button
    parent.rectMode(PConstants.CORNER); 
    int btnW = 200;
    int btnH = 50;
    int btnX = parent.width / 2 - btnW / 2;
    int btnY = parent.height / 2 + 120;
    
    if (parent.mouseX > btnX && parent.mouseX < btnX + btnW && parent.mouseY > btnY && parent.mouseY < btnY + btnH) {
        parent.fill(100);
    } else {
        parent.fill(50);
    }
    parent.stroke(255);
    parent.rect(btnX, btnY, btnW, btnH);
    
    parent.fill(255);
    parent.textSize(20);
    parent.textAlign(PConstants.CENTER, PConstants.CENTER);
    parent.text(SAVE_N_RETURN, parent.width / 2, btnY + btnH / 2 - 2);

  }

  private void handleGameOverClick() {
    int btnW = 200;
    int btnH = 50;
    int btnX = parent.width / 2 - btnW / 2;
    int btnY = parent.height / 2 + 120;
    
    // If user clicked inside the button area
    if (parent.mouseX > btnX && parent.mouseX < btnX + btnW && parent.mouseY > btnY && parent.mouseY < btnY + btnH) {
        saveAndReturn();
    }
  }

  public void handleGameOverKey(char k, int code){
    if (code == PConstants.LEFT) {
        if (cursorIndex > 0) cursorIndex--;
    } else if (code == PConstants.RIGHT) {
        if (cursorIndex < playerNameInput.length()) cursorIndex++;
    } else if (k == PConstants.BACKSPACE || code == 8) {
        if (cursorIndex > 0) {
            // Remove the character exactly behind the cursor
            playerNameInput = playerNameInput.substring(0, cursorIndex - 1) + playerNameInput.substring(cursorIndex);
            cursorIndex--;
        }
    } else if (code == PConstants.DELETE || k == 127) { 
        // Support for the Delete key (removes character in front of cursor)
        if (cursorIndex < playerNameInput.length()) {
            playerNameInput = playerNameInput.substring(0, cursorIndex) + playerNameInput.substring(cursorIndex + 1);
        }
    } else if (k == PConstants.ENTER || k == PConstants.RETURN || code == 10) {
        saveAndReturn();
    } else if (k >= 32 && k <= 126 && playerNameInput.length() < 100) {
        // Standard typing: Insert the character exactly where the cursor is!
        playerNameInput = playerNameInput.substring(0, cursorIndex) + k + playerNameInput.substring(cursorIndex);
        cursorIndex++;
    }
  }

  private void saveAndReturn() {
    String finalName = playerNameInput.trim();
    if (finalName.isEmpty()) {
        finalName = "Anonymous";
    }
    
    final int timePlayedSeconds = sessionFramesPlayed / 60;
    
    // Trigger Save with dynamically entered name!
    SaveGameManager.saveGameSession(
        parent, 
        AsteroidConstants.GAME_MODE.name(), 
        score, 
        timePlayedSeconds, 
        finalName 
    );
    
    gameState = AsteroidConstants.GameState.MENU_MAIN;
  }



  private String fetchHighScore(final int currentScore){
    JSONObject highScoreObject = SaveGameManager.getLocalHighScore(parent, AsteroidConstants.GAME_MODE.name());
    long highScore = Objects.nonNull(highScoreObject) ? Math.max(currentScore, highScoreObject.getLong("score")) : 0;
    return PApplet.nf((int) highScore, 9);
  }

  private void transitionToGameOver(){
    gameState = AsteroidConstants.GameState.GAME_OVER;
    playerNameInput = ""; //reset name again
    cursorIndex = 0; //reset cursor index

    currentHighScoreDisplay = fetchHighScore(score);
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

  public void setHud(final HUD hud){
    this.hud = hud;
  }
  public HUD getHud(){
    return hud;
  }
}
