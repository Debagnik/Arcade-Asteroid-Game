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
private boolean isLeft, isRight, isUp;
private int level = 0;

void setup() {
  //create a window
  //Using P2D renderer
  size(1080, 608, P2D);
  pixelDensity(1);

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
}

void draw() {
  //Set BG to a a dark color with RGB values
  background(20, 20, 30);

  shipMechanics();
  // Weapons Handling
  weapon.displayAndUpdate();
  //Asteroid mechanics
  asteroidsMechanics();
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
    weapon.fire(ship);
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
  ArrayList<Laser> activeLasers = weapon.getLasers();
  HashSet<Asteroid> spawnChildAsteroids = new HashSet<Asteroid>();
  HashSet<Asteroid> despawnParentAsteroids = new HashSet<Asteroid>();
  HashSet<Laser> deactivateLasers = new HashSet<Laser>();

  for (Laser l : activeLasers) {
    // Optimization: If this laser is already marked inactive (e.g. somehow hit twice), skip it
    if (deactivateLasers.contains(l)) {
      continue;
    }

    for (Asteroid a : asteroids) {
      // Optimization: If asteroid is already destroyed by another laser in this frame, skip it
      if (despawnParentAsteroids.contains(a)) {
        continue;
      }

      // Check Hit collision
      if (PhysicsHelper.checkLaserCollision(l, a)) {
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
  for (Laser l : deactivateLasers) {
    l.setActive(false);
  }

  // Asteroid Vs Asteroid Collision Mechanics
  //check for collision mechanics on game loop
  for (int i = 0; i < asteroids.size(); ++i) {
    for (int j = i + 1; j < asteroids.size(); ++j) {
      Asteroid a1 = asteroids.get(i);
      Asteroid a2 = asteroids.get(j);

      //perform collistion detection
      PhysicsHelper.checkCollision(a1, a2);
    }
  }

  if (asteroids.size() == 0) {
    setLevel(getLevel() + 1);
    for (int i = 0; i < AsteroidConstants.INITIAL_ASTEROID_COUNT + getLevel(); i++) {
      asteroids.add(new Asteroid(ship, AsteroidConstants.ASTEROID_SHIP_SAFE_DISTANCE));
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

