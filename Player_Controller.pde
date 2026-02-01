/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Player_Controller.pde
 */

public class PlayerController {

  private boolean isLeft;
  private boolean isRight;
  private boolean isUp;

  private boolean enableControls = true;

  public void activateRespawnMechanics() {
    respawnTimer--;
    //Animate Debris
    explosions.displayAndUpdate();

    // keeping the asteroids alive in the BG
    collisionMechanics.asteroidsMechanics();
    weapon.displayAndUpdate();

    //respawns
    if (respawnTimer == 0) {
      ship = new Spacecraft(true); //Uses the invincibility constructor
      collisionMechanics.setShip(ship);
      // reset the inputs
      isLeft = false;
      isRight = false;
      isUp = false;
    }
  }

  public void shipMechanics() {

    if(!enableControls){
      setLeft(false);
      setUp(false);
      setRight(false);
    }

    if (isLeft) {
      ship.rotateShip(-1); // rotate anti-clockwise
    } else if (isRight) {
      ship.rotateShip(1); // Rotate clockwise
    }
    if (isUp) {
      ship.thrust(); //move forward
    }

    //display and update ship.
    ship.update();
    ship.display();
  }

  public void animateShipDestroy(Spacecraft playerShip) {
    respawnTimer = AsteroidConstants.RESPAWN_TIMER;
    explosions.animateShipExplosion(playerShip);

    //Reseting the inputs for extra safety
    isLeft = false;
    isRight = false;
    isUp = false;
  }

  public void keyPressed() {
    if(!enableControls) return; //Exit code

    if (keyCode == LEFT) isLeft = true;
    if (keyCode == RIGHT) isRight = true;
    if (keyCode == UP) isUp = true;
    // Firing Logic:
    // We check for Spacebar HERE instead of using a boolean flag.
    // This ensures 1 press = 1 bullet.
    if (enableControls && key == ' ' && respawnTimer == 0) {
      weapon.fire(ship, getLevel());
    }
  }

  public void keyReleased() {
    if (keyCode == UP) isUp = false;
    if (keyCode == LEFT) isLeft = false;
    if (keyCode == RIGHT) isRight = false;
  }

  // Accessors
  public boolean isLeft() {
    return isLeft;
  }

  public void setLeft(boolean isLeft) {
    this.isLeft = isLeft;
  }

  public boolean isRight() {
    return isRight;
  }

  public void setRight(boolean isRight) {
    this.isRight = isRight;
  }

  public boolean isUp() {
    return isUp;
  }

  public void setUp(boolean isUp) {
    this.isUp = isUp;
  }

  public boolean isEnableControls(){
    return enableControls;
  }

  public void setEnableControls(final boolean enableControls){
    this.enableControls = enableControls;
    if(!enableControls){
      setUp(false);
      setRight(false);
      setLeft(false);
    }

  }
}
