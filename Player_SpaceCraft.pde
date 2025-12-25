/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Player_SpaceCraft.pde
 */

public class Spacecraft {
    // Spacecraft Variables
    private PVector position;       //Position vector of the spacecraft
    private float heading;          //The angle of the ship is pointing to (Radians)
    private float size;             //The size of the ship
    private float rotationSpeed;    //The speed of rotation
    private PVector velocity;       //The velocity vector of the ship
    private PVector acceleration;   //The acceleration vector of the ship
    private int invincibilityTimer; //The time for player invincibility

    private boolean isThrusting;    //Flag to indicate if the ship is currently thrusting
    private boolean isInvincible;   //Invincibility Period after player ship death

    //Default Constructor of Spacecraft
    public Spacecraft() {
       initPhysics();
       // for the invincible flag
       activateInvincibility(AsteroidConstants.INVINCIBLE_TIMER);
    }

    //Constructor for invinsible player
    public Spacecraft(final boolean isInvincible){
        initPhysics();
        if(isInvincible){
            activateInvincibility(AsteroidConstants.INVINCIBLE_TIMER);
        } else {
            this.isInvincible = false;
            this.invincibilityTimer = 0;
        }
    }

    private void initPhysics(){
        //Initial ship position (spawn position) and parameters
        position = new PVector(width/2, height/2); // Spawn at center of screen
        velocity = new PVector(0, 0); // Initial velocity is zero
        acceleration = new PVector(0, 0); // Initial acceleration is zero
        heading = -AsteroidConstants.PI/2; // head towards 12 o clock
        size = AsteroidConstants.SHIP_SIZE; 
        rotationSpeed = AsteroidConstants.SHIP_ROTATE_SPEED;
        isThrusting = false;

    }

    private void activateInvincibility(int invincibilityTimer){
        this.isInvincible = true;
        this.invincibilityTimer = invincibilityTimer;
    }

    public void update(){
        // Apply Newtonian Physics for movement
        velocity.add(acceleration); // Update velocity based on acceleration
        velocity.limit(AsteroidConstants.SHIP_MAX_SPEED); // Limit max speed
        velocity.mult(AsteroidConstants.SHIP_FRICTION); // Apply friction
        position.add(velocity); // Update position based on velocity
        acceleration.mult(0); // Reset acceleration

        PhysicsHelper.screenWrap(position, size, width, height); // Screen wrapping logic (same as asteroids)

        // Apply invincibility
        if(AsteroidConstants.GAME_MODE == AsteroidConstants.GameModeEnum.TEST){
            this.isInvincible = true;
        } else if(invincibilityTimer > 0){
            invincibilityTimer--;
            isInvincible = true;
        } else {
            isInvincible = false;
        }
    }

    //Input method to change angle
    //direction: -1 for anti-clockwise, +1 for clockwise
    public void rotateShip(final int direction){
        heading = heading + direction * rotationSpeed;
        // Normalize heading to stay within [-PI, PI] or [0, TWO_PI]
        heading = heading % AsteroidConstants.TWO_PI;
    }

    // Displays the spacecraft
    public void display(){

        //Blink if invinsible
        if(AsteroidConstants.GAME_MODE != AsteroidConstants.GameModeEnum.TEST){
            if(isInvincible && invincibilityTimer > 0){
                if((invincibilityTimer / 10) % 2 == 0){ // dont draw in every 10 frames.
                    return;
                }
            }
        }

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
        // calculate force vector based on the angle of attack
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

    // Access APIs and Actions.(Getters/Setters)
    public PVector getPosition() {
        return position.copy();
    }

    public float getHeading() {
        return heading;
    }
    
    public float getSize() {
        return size;
    }

    public PVector getVelocity() {
        return velocity.copy();
    }

    public void setPosition(PVector position) {
        this.position = position;
    }

    public void setHeading(float heading) {
        this.heading = heading;
    }
    
    public void setSize(float size) {
        this.size = size;
    }

    public void setVelocity(PVector velocity) {
        this.velocity = velocity;
    }

    public boolean getIsInvincible(){
        return isInvincible;
    }

    public void setIsInvincible(boolean isInvincible){
        this.isInvincible = isInvincible;
    }

    
}