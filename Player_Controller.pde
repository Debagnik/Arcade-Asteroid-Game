/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Player_Controller.pde
 */

private void activateRespawnMechanics() {
  respawnTimer--;
  //Animate Debris
  explosions.displayAndUpdate();

  // keeping the asteroids alive in the BG
  asteroidsMechanics();
  weapon.displayAndUpdate();

  //respawns
  if (respawnTimer == 0) {
    ship = new Spacecraft(true); //Uses the invincibility constructor

    // reset the inputs
    isLeft = false;
    isRight = false;
    isUp = false;
  }
}

private void shipMechanics() {

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

public void keyPressed() {
  if (keyCode == LEFT) isLeft = true;
  if (keyCode == RIGHT) isRight = true;
  if (keyCode == UP) isUp = true;
  // Firing Logic:
  // We check for Spacebar HERE instead of using a boolean flag.
  // This ensures 1 press = 1 bullet.
  if (key == ' ') {
    weapon.fire(ship, getLevel());
  }
}

public void keyReleased() {
  if (keyCode == UP) isUp = false;
  if (keyCode == LEFT) isLeft = false;
  if (keyCode == RIGHT) isRight = false;
}

private void animateShipDestroy(Spacecraft playerShip) {
  respawnTimer = AsteroidConstants.RESPAWN_TIMER;
  explosions.animateShipExplosion(playerShip);

  //Reseting the inputs for extra safety
  isLeft = false;
  isRight = false;
  isUp = false;
  
}
