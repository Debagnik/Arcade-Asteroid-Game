/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Asteroid_Object.pde
 */

public class Asteroid {
  // The Default class of the Asteroids
  private PVector position;
  private PVector velocity;
  private float radius;

  //Variables for asteroids "Jaggedness" and "Rockiness"
  private int totalPoints;
  private float[] offset;
  private float mass; //Scaler Quantity, find explanation below comment

  private AsteroidConstants.AsteroidExplosionTypeEnum explosionType;

  //Default constructor of the asteroids
  public Asteroid() {
    //Spawns at a random location
    position = new PVector(random(width), random(height));

    //gives a random speed and direction | PVector.random2D() gives a vector of length 1 pointing in a random direction
    velocity = PVector.random2D();
    velocity.mult(random(1, 3));
    velocity.limit(AsteroidConstants.ASTEROID_MAX_SPEED + getLevel()); //Limiting max speed

    // Set a random size
    radius = random(AsteroidConstants.MIN_ASTEROID_SIZE, AsteroidConstants.MAX_ASTEROID_SIZE);
    determineExplosionType();

    // Generate the jagged shape data
    generateShapeData();
  }

  //Child Constructor (Used when the parent asteroids splits)
  public Asteroid(PVector parentPosition, float newRadius){
    position = parentPosition.copy(); //spawns where parent died
    position.add(PVector.random2D().mult(newRadius * 0.5)); //Add small random offset to prevent immediate collision with sibling
    radius = newRadius;
    determineExplosionType();

    // Smaller asteroids fly faster!
    velocity = PVector.random2D();
    velocity.mult(random(2, 4)); 
    velocity.limit(AsteroidConstants.ASTEROID_MAX_SPEED + getLevel());

    // Generate Jagged shapes on child as well
    generateShapeData();

    
  }

  // Constructor for spawing new asteroid for level > 0 
  public Asteroid(Spacecraft ship, float safeDist){
    velocity = PVector.random2D();
    velocity.mult(random(1, 3));
    velocity.limit(AsteroidConstants.ASTEROID_MAX_SPEED + getLevel());
    radius = random(AsteroidConstants.MIN_ASTEROID_SIZE, AsteroidConstants.MAX_ASTEROID_SIZE);

    determineExplosionType();

    generateShapeData();

    int attempts = 0;
    do {
      position = new PVector(random(width), random(height));
      attempts++;
      // println(attempts);
    } while (PVector.dist(position, ship.getPosition()) < safeDist && attempts < 100);
  }

  private void determineExplosionType(){
    final float ratio = getRadius() / AsteroidConstants.MAX_ASTEROID_SIZE;
    if(ratio > 0.6){
      this.explosionType = AsteroidConstants.AsteroidExplosionTypeEnum.BIG_EXPLOSION;
    } else if (ratio > 0.4){
      this.explosionType = AsteroidConstants.AsteroidExplosionTypeEnum.MEDIUM_EXPLOSION;
    } else {
      this.explosionType = AsteroidConstants.AsteroidExplosionTypeEnum.SMALL_EXPLOSION;
    }
  }

  // Asteroid Movement Animation
  public void update() {
    //updates position wrt velocity for movement
    position.add(velocity);

    //Arcade Style Screen Wrapping logic
    PhysicsHelper.screenWrap(position, radius, width, height);
  }

  public void display() {
    pushStyle();      //Isolate Style to not affect other game objects
    noFill();         //Shows just the wireframe for the classic arcade style
    stroke(255);      //Just white lines on the the wires
    strokeWeight(2);  //the whitelines boldness

    //Draw the asteroid as a polygon with random offsets for jaggedness
    pushMatrix();
    translate(position.x, position.y);

    // Draw an asteroid
    //connecting the dots
    createUniqueShape();

    //ellipse(position.x, position.y, radius*2, radius*2);
    popMatrix();// Restore coordinate system
    popStyle();
  }

  //draws jagged and rocky shapes for asteroids
  private void createUniqueShape() {
    beginShape();
    for(int i=0; i < totalPoints; i++){
      //Calculate the angle for the specific vertex
      //map() converts vertex i to an angle (0 - 2*PI)
      float angle = map(i, 0, totalPoints, 0, AsteroidConstants.TWO_PI);
      float r = radius + offset[i];

      float x = PhysicsHelper.polarToCartesian(r, angle, AsteroidConstants.TrigonometricFunctionEnum.COSINE);
      float y = PhysicsHelper.polarToCartesian(r, angle, AsteroidConstants.TrigonometricFunctionEnum.SINE);

      vertex(x, y);

    }
    endShape(CLOSE);
  }

  // --- HELPER METHOD: Generates the random shape numbers ---
  // This is used by BOTH constructors to ensure every asteroid (big or small) has a shape.
  private void generateShapeData() {
    //Set the random jaggedness and rockiness by picking a random points (between 5 and 15) around the asteroid to turn the ellipse into a polygon
    totalPoints = floor(random(5, 15));
    //Then Offset array to store the random offset for each point by pushing in and pulling in the polygon vertexes
    offset = new float[totalPoints];

    //create unique jaggedness
    for (int i = 0; i < totalPoints; i++) {
      //Offset each point the radius by -5 to +5 pixels for each point
      offset[i] = random(-radius * 0.5, radius * 0.5);
    }

    //Mass Calculate
    mass = radius * radius;
  }

  // Generic APIs (Getters/Setters)
  public PVector getPosition() {
    return position.copy();
  }
  
  public PVector getVelocity() {
    return velocity.copy(); 
  }
  
  public float getRadius() {
    return radius;
  }
  
  public float getMass() {
    return mass;
  }

  public void setPosition(PVector position) {
    this.position = position;
  }
  
  public void setVelocity(PVector velocity) {
    this.velocity = velocity; 
  }
  
  public void setRadius(float radius) {
    this.radius = radius;
  }
  
  public void setMass(float mass) {
    this.mass = mass;
  }

  public AsteroidConstants.AsteroidExplosionTypeEnum getExplosionType(){
    return explosionType;
  }

  public void setExplosionType(AsteroidConstants.AsteroidExplosionTypeEnum explosionType){
    this.explosionType = explosionType;
  }
    
}

