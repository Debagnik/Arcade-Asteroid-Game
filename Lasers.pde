public class Laser{
    PVector position;
    PVector velocity;
    int ttl;
    boolean active;

    //Default Constructor
    public Laser(PVector shipPos, float angle){
        // Calculate Spawn Position (The Nose of the ship)
        // We don't want the laser spawning inside the ship's center.
        // We calculate the tip based on the ship's size and heading.
        float noseX = shipPos.x + (AsteroidConstants.SHIP_SIZE * cos(angle));
        float noseY = shipPos.y + (AsteroidConstants.SHIP_SIZE * sin(angle));

        position = new PVector(noseX, noseY);

        // Calculate Velocity
        // It moves in the direction of the angle, but faster than the ship
        velocity = PVector.fromAngle(angle);
        velocity.mult(AsteroidConstants.LASER_SPEED);

        ttl = AsteroidConstants.LASER_LIFESPAN;
        active = true;
    }

    public void update(){
        position.add(velocity);

        // Screen Wrap
        PhysicsHelper.screenWrap(position, 1.0, width, height);

        // Decrease TTL
        ttl--;
        if(ttl < 0){
            active = false;
        }

    }

    public void display(){
        pushStyle();
        stroke(255, 255, 255); // While Lazer
        ellipse(position.x, position.y, 0.5, 0.5);
        // TODO: Trail Logic
        //println("Drawing laser at: " + position.x + ", " + position.y);
        popStyle();
    }

}