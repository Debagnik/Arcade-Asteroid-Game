/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Asteroids.pde
 */
 
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

  //Init Asteroids List
  asteroids = new ArrayList<Asteroid>();
  //create 5 asteroids to start game.
  for (int i = 0; i < AsteroidConstants.INITIAL_ASTEROID_COUNT; i++) {
    asteroids.add(new Asteroid());
  }

  ship = new Spacecraft();
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
  ArrayList<Asteroid> spawnChildAsteroids = new ArrayList<Asteroid>();
  ArrayList<Asteroid> despawnParentAsteroids = new ArrayList<Asteroid>();
  ArrayList<Laser> deactivateLasers = new ArrayList<Laser>();

  for (Laser l : activeLasers) {
    // Optimization: If this laser is already marked inactive (e.g. somehow hit twice), skip it
    if(deactivateLasers.contains(l)){
      continue;
    }

    for (Asteroid a : asteroids) {
      // Optimization: If asteroid is already destroyed by another laser in this frame, skip it
      if(despawnParentAsteroids.contains(a)){
        continue;
      }

      // Check Hit collision
      if (PhysicsHelper.checkLaserCollision(l, a)) {
        if (a.radius > AsteroidConstants.MIN_ASTEROID_SIZE) {
          // Asteroid Split logic and spawning logic
          spawnChildAsteroids.add(new Asteroid(a.position, (a.radius)/2.0));
          spawnChildAsteroids.add(new Asteroid(a.position, (a.radius)/2.0));

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
  for(Laser l : deactivateLasers){
    l.active = false;
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
    level++;    
    for (int i = 0; i < AsteroidConstants.INITIAL_ASTEROID_COUNT + level; i++) {
       asteroids.add(new Asteroid());
    }
  }
}
