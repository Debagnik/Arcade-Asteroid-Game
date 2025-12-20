// Asteroids Clone Game
// License MIT

// Main Game File

//Define Global Variables
ArrayList<Asteroid> asteroids; //adds a list of asteriods
Spacecraft ship; //Adds a player ship
WeaponsController weapon;
boolean isLeft, isRight, isUp;
int level = 1;

void setup() {
  //create a window
  //Using P2D renderer
  size(1080, 608, P2D);
  pixelDensity(1);

  //Turn off Anti-aliasing
  smooth();

  //Init Asteroids List
  asteroids = new ArrayList<Asteroid>();
  int initalAsteroidCount = AsteroidConstants.INITIAL_ASTEROID_COUNT;
  //create 5 asteroids to start game.
  for (int i = 0; i < initalAsteroidCount; i++) {
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

  for (Laser l : activeLasers) {
    for (Asteroid a : asteroids) {
      // Check Hit collision
      if (PhysicsHelper.checkLaserCollision(l, a)) {
        if (a.radius > AsteroidConstants.MIN_ASTEROID_SIZE) {
          float newRadius = a.radius / 2.0;
          // Asteroid Split logic
          asteroids.add(new Asteroid(a.position, newRadius));
          asteroids.add(new Asteroid(a.position, newRadius));
        }
        asteroids.remove(a);
        l.active = false;
        break;
      }
    }
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
