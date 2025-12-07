// Asteroids Clone Game
// License MIT

// Main Game File

//Define Global Variables
ArrayList<Asteroid> asteroids;

void setup(){
  //create a window
  //Using P2D renderer
  size(450, 400, P2D);
  
  //Turn off Anti-aliasing
  smooth();
  
  //Init Asteroids List
  asteroids = new ArrayList<Asteroid>();
  int initalAsteroidCount = AsteroidConstants.INITIAL_ASTEROID_COUNT;
  //create 5 asteroids to start game.
  for(int i = 0; i < initalAsteroidCount; i++){
    asteroids.add(new Asteroid());
  }
  
  
}

void draw(){
  //Set BG to a a dark color with RGB values
  background(20, 20, 30); //<>//
  
  //Visual Test: Draw a simple text in the center of the screen
  //fill(255);
  //textAlign(CENTER);text("Test Text", width/2, height/2);
  
  for (int i = asteroids.size() - 1; i >= 0; i--) {
    Asteroid asteroid = asteroids.get(i);
    asteroid.update();
    asteroid.display();
  }

}
