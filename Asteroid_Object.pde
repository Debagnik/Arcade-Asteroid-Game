class Asteroid {
  // The Default class of the Asteroids
  PVector position;
  PVector velocity;
  float radius;

  //Default constructor of the asterroids
  Asteroid() {
    //Spawns at a random location
    position = new PVector(random(width), random(height));

    //gives a random speed and direction | PVector.random2D() gives a vector of length 1 pointing in a random direction
    velocity = PVector.random2D();
    velocity.mult(random(1, 3));

    // Set a random size
    radius = random(15, 30);
  }

  // Asteroid Movement Animation
  void update() {
    //updates position wrt velocity for movement
    position.add(velocity);

    //Arcade Style Screen Wrapping logic
    if (position.x > width + radius) position.x = -radius;
    if (position.x < -radius) position.x = width + radius;
    if (position.y > height + radius) position.y = -radius;
    if (position.y < -radius) position.y = height + radius;
  }

  void display() {
    pushStyle();      //Isolate Style to not affect other game objects
    noFill();         //Shows just the wireframe for the classic arcade style
    stroke(255);      //Just white lines on the the wires
    strokeWeight(2);  //the whitelines boldness


    // Draw an asteroid
    ellipse(position.x, position.y, radius*2, radius*2);
    popStyle();
  }
}

