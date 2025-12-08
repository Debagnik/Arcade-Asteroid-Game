public class Spacecraft {
    // Spacecraft Variables
    PVector position;   //Position vector of the spacecraft
    float heading;      //The angle of the ship is pointing to (Radians)
    float size;         //The size of the ship
    float rotationSpeed;//The speed of rotation

    //Default Consteructor of Spacecraft
    public Spacecraft() {
        //Initial ship position (spawn position)
        position = new PVector(width/2, height/2);

        //head toward 12 o clock
        heading = -AsteroidConstants.PI/2;

        size = AsteroidConstants.SHIP_SIZE;
        rotationSpeed = AsteroidConstants.SHIP_ROTATE_SPEED;

    }

    public void update(){
        //TODO: Ship Thrust and movement logic and physics
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

        popMatrix();
        popStyle();
    }

    // Draws spaceship
    public void drawSpaceShip(){
        /*  Because we translated and rotated, we draw this as if the ship 
         *  is pointing to the RIGHT (0 degrees) relative to itself.
         *  The "Nose" is at x = r
         *  The "Tail" is at x = -r
        */
        float noseX = size;
        float noseY = 0;

        float rearX = -size;
        float rearY = -size; // Top Left
        float rearY2 = size; // Bottom left

        //draw triangle
        triangle(noseX, noseY, rearX, rearY, rearX, rearY2);

        //Draw a line inside to show the head
        line (0, 0, size, 0);

    }
    
}