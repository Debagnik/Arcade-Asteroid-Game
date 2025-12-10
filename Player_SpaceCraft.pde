public class Spacecraft {
    // Spacecraft Variables
    PVector position;       //Position vector of the spacecraft
    float heading;          //The angle of the ship is pointing to (Radians)
    float size;             //The size of the ship
    float rotationSpeed;    //The speed of rotation
    PVector velocity;       //The velocity vector of the ship
    PVector acceleration;   //The acceleration vector of the ship

    boolean isThrusting;    //Flag to indicate if the ship is currently thrusting

    //Default Consteructor of Spacecraft
    public Spacecraft() {
        //Initial ship position (spawn position) and parameters
        position = new PVector(width/2, height/2); // Spawn at center of screen
        velocity = new PVector(0, 0); // Initial velocity is zero
        acceleration = new PVector(0, 0); // Initial acceleration is zero
        heading = -AsteroidConstants.PI/2; // head towards 12 o clock
        size = AsteroidConstants.SHIP_SIZE; 
        rotationSpeed = AsteroidConstants.SHIP_ROTATE_SPEED;
        isThrusting = false;
    }

    public void update(){
        // Apply Newtonian Physics for movement
        velocity.add(acceleration); // Update velocity based on acceleration
        velocity.limit(AsteroidConstants.SHIP_MAX_SPEED); // Limit max speed
        velocity.mult(AsteroidConstants.SHIP_FRICTION); // Apply friction
        position.add(velocity); // Update position based on velocity
        acceleration.mult(0); // Reset acceleration

        PhysicsHelper.screenWrap(position, size, width, height); // Screen wrapping logic (same as asteroids)
    }

    //Input method to change angle
    //direction: -1 for anti-clockwise, +1 for clockwise
    public void rotateShip(final int direction){
        heading = heading + direction * rotationSpeed;
    }

    // Displays the spacecraft
    public void display(){
        pushStyle();
        noFill();
        stroke(255); //White
        strokeWeight(2); //Width of the stroke;
        pushMatrix();

        // Move origin to ship position
        translate(position.x, position.y);

        // Rotate the entire grid to match the ships head
        rotate(heading);

        //draw ship
        drawSpaceShip();
        if(isThrusting){
            drawExhaust();
        }

        isThrusting = false; // Reset thrusting flag
        popMatrix();
        popStyle();
    }

    // Draws spaceship
    public void drawSpaceShip(){
        beginShape();
        vertex(-size, -size);
        vertex(size, 0);
        vertex(-size, size);
        vertex(-size * 0.5, 0);
        endShape(CLOSE);

        line(-size/2, -size * 0.75, -size/2, size * 0.75);

    }

    public void thrust(){
        // calculate force vector based on the anglr of attack
        PVector force = PVector.fromAngle(heading);
        force.mult(AsteroidConstants.SHIP_THRUST_POWER);

        acceleration.add(force);
        isThrusting = true;
    }

    //Draws a blinking fire
    private void drawExhaust(){
        if (random(1) > 0.3) { 
            stroke(255);
            fill(255);
            
            beginShape();
            // Start at the "V" indent of the ship
            vertex(-size * 0.5, size * 0.5); 
            vertex(-size * 0.5, -size * 0.5);
            
            // The tip of the flame extends backward
            // We randomize the length slightly for animation
            float flicker = random(size, size * 1.5);
            vertex(-flicker, 0);
            endShape(CLOSE);
        }
    }
    
}