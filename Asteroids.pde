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
private boolean isLeft, isRight, isUp;
private int level = 10;
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
  //create 5 asteroids to start game.
  for (int i = 0; i < AsteroidConstants.INITIAL_ASTEROID_COUNT; i++) {
    asteroids.add(new Asteroid(ship, AsteroidConstants.ASTEROID_SHIP_SAFE_DISTANCE));
  }
  // Init Weapons controller
  weapon = new WeaponsController();

  //Init Explosion Controller
  explosions = new ExplosionController();

  // Init ufo controller
  ufoController = new UFOController(explosions);
  
}

void draw() {
  //Set BG to a a dark color with RGB values
  background(20, 20, 30);

  if (respawnTimer > 0) {
    activateRespawnMechanics();
  } else {
    activeGameplayHandler();
  }
}

private void activeGameplayHandler() {
  shipMechanics();
  // Weapons Handling
  weapon.displayAndUpdate();
  //Explosion handling
  explosions.displayAndUpdate();
  //UFO Mechanics
  ufoController.update(getLevel(), asteroids, weapon.getPlayerLasers());
  //Asteroid mechanics
  asteroidsMechanics();
  //UFO Hits mechanism
  checkUFOAttacksOnPlayer();
  //player collision mechanics
  checkPlayerCollision();
}

private void checkPlayerCollision() {
  // Asteroid vs PlayerShip Collision
  HashSet<Asteroid> spawnChildAsteroids = new HashSet<Asteroid>();
  HashSet<Asteroid> despawnParentAsteroids = new HashSet<Asteroid>();
  for (Asteroid a : asteroids) {
    final boolean hit = PhysicsHelper.checkShip2AsteroidCollision(ship, a);
    if (hit) {
      despawnParentAsteroids.add(a);
      if (a.getRadius() > AsteroidConstants.MIN_ASTEROID_SIZE) {
        spawnChildAsteroids.add(new Asteroid(a.getPosition(), a.getRadius()/2.0));
        spawnChildAsteroids.add(new Asteroid(a.getPosition(), a.getRadius()/2.0));
      }
      animateShipDestroy(ship);
      break;
    }
  }
  asteroids.removeAll(despawnParentAsteroids);
  asteroids.addAll(spawnChildAsteroids);
}

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

// Asteroid Collision mechanics
private void asteroidsMechanics() {
  for (Asteroid a : asteroids) {
    a.update();
    a.display();
  }

  // LASER VS ASTEROID COLLISION
  // Get all active lasers
  ArrayList<PlayerLaser> activeLasers = weapon.getPlayerLasers();
  HashSet<Asteroid> spawnChildAsteroids = new HashSet<Asteroid>();
  HashSet<Asteroid> despawnParentAsteroids = new HashSet<Asteroid>();
  HashSet<PlayerLaser> deactivateLasers = new HashSet<PlayerLaser>();

  for (PlayerLaser l : activeLasers) {
    // Optimization: If this laser is already marked inactive (e.g. somehow hit twice), skip it
    if (deactivateLasers.contains(l)) {
      continue;
    }
    //Logger.log(l, getLevel());

    for (Asteroid a : asteroids) {
      // Optimization: If asteroid is already destroyed by another laser in this frame, skip it
      if (despawnParentAsteroids.contains(a)) {
        continue;
      }
      //Logger.log(a, getLevel());

      // Check Hit collision
      if (PhysicsHelper.checkLaserCollision(l, a)) {
        explosions.animateAsteroidExplosion(a); //Asteroid explosion Animation
        
        if (a.getRadius() > AsteroidConstants.MIN_ASTEROID_SIZE) {
          // Asteroid Split logic and spawning logic
          spawnChildAsteroids.add(new Asteroid(a.getPosition(), (a.getRadius())/2.0));
          spawnChildAsteroids.add(new Asteroid(a.getPosition(), (a.getRadius())/2.0));
        }
        despawnParentAsteroids.add(a);
        deactivateLasers.add(l);
        break; // Stops checking this Laser
      }
    }
  }

  // Safely add/remove child/parent asteroids
  asteroids.removeAll(despawnParentAsteroids);
  asteroids.addAll(spawnChildAsteroids);

  // Safely deactivate Lasers
  for (PlayerLaser l : deactivateLasers) {
    l.setActive(false);
  }

  // Asteroid Vs Asteroid Collision Mechanics
  //check for collision mechanics on game loop
  for (int i = 0; i < asteroids.size(); ++i) {
    for (int j = i + 1; j < asteroids.size(); ++j) {
      Asteroid a1 = asteroids.get(i);
      Asteroid a2 = asteroids.get(j);

      //Logger.log(a1, getLevel());
      //Logger.log(a2, getLevel());
      //perform collistion detection
      PhysicsHelper.checkCollision(a1, a2);
    }
  }

  //Logger.log(ship, getLevel());
  //Logger.log(weapon, getLevel());

  // Level Up and infinite gameplay logic
  if (asteroids.size() == 0) {
    setLevel(getLevel() + 1);
    for (int i = 0; i < AsteroidConstants.INITIAL_ASTEROID_COUNT + getLevel(); i++) {
      asteroids.add(new Asteroid(ship, AsteroidConstants.ASTEROID_SHIP_SAFE_DISTANCE));
    }
  }
}

private void animateShipDestroy(Spacecraft playerShip) {
  respawnTimer = AsteroidConstants.RESPAWN_TIMER;
  explosions.animateShipExplosion(playerShip);

  //Reseting the inputs for extra safety
  isLeft = false;
  isRight = false;
  isUp = false;
}

private void checkUFOAttacksOnPlayer(){
  ArrayList<UFO> activeUFOs = ufoController.getActiveUFOs();
  for(UFO ufo : activeUFOs){
    // If UFO wants a suicide route.
    float distBody = PVector.dist(ship.getPosition(), ufo.getPosition());
     if(distBody < (ufo.getRadius() + AsteroidConstants.SHIP_SIZE)){
      if(ship.takeDamage(100)){
        animateShipDestroy(ship);
      }
      explosions.animateUFOExplosion(ufo);
      //Logger.log(ship);
      //Logger.log(ufo);
     }

     // If UFO laser hits ship.
     for(EnemyLaser el : ufo.getUFOLasers()){
      if(!el.isActive()){
        continue;
      }
      float distLaser = PVector.dist(ship.getPosition(), el.getPosition());
      //Collision check
      if (distLaser < (AsteroidConstants.SHIP_SIZE + (AsteroidConstants.LASER_SIZE / 2.0))) {
        // Deals with Ship Damage
        boolean isDed = ship.takeDamage(el.getDamage());
        el.setActive(false);

        if(isDed){
          animateShipDestroy(ship);
        }
      }

     }

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

