// Asteroids Clone Game
// License MIT

// Main Game File

//Define Global Variables
ArrayList<Asteroid> asteroids; //adds a list of asteriods
Spacecraft ship; //Adds a player ship
boolean isLeft, isRight, isUp, isSpaceBar;

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
}

void draw() {
  //Set BG to a a dark color with RGB values
  background(20, 20, 30);

  //Visual Test: Draw a simple text in the center of the screen
  //fill(255);
  //textAlign(CENTER);text("Test Text", width/2, height/2);
  //player input handling
  shipMechanics();
  //Asteroid mechanics
  asteroidsMechanics();
}

private void asteroidsMechanics() {
  for (int i = asteroids.size() - 1; i >= 0; i--) {
    Asteroid asteroid = asteroids.get(i);
    asteroid.update();
    asteroid.display();
  }

  //check for collision mechanics on game loop
  for (int i = 0; i < asteroids.size(); ++i) {
    for (int j = i + 1; j < asteroids.size(); ++j) {
      Asteroid a1 = asteroids.get(i);
      Asteroid a2 = asteroids.get(j);

      //perform collistion detection
      PhysicsHelper.checkCollision(a1, a2);
    }
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

public void keyPressed(){
  if(keyCode == LEFT) isLeft = true;
  if(keyCode == RIGHT) isRight = true;
  if(keyCode == UP) isUp = true;
}

public void keyReleased() {
  if (keyCode == UP) isUp = false;
  if (keyCode == LEFT) isLeft = false;
  if (keyCode == RIGHT) isRight = false;
}
