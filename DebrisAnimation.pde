/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: DebrisAnimation.pde
 */

public class ShipDebris{
    protected PVector position;
    protected PVector velocity;
    protected float length;
    protected float angle;
    protected float spin;
    protected int lifespan;

    //Default Constructor
    public ShipDebris(final PVector position){
        this.position = position.copy();
        velocity = PVector.random2D();
        velocity.mult(random(1, 3));

        length = random(5, 15);
        angle = random(TWO_PI);
        spin = random(-0.2, 0.2);
        lifespan = AsteroidConstants.RESPAWN_TIMER;
    }

    public void update(){
        position.add(velocity);
        angle = angle + spin;
        lifespan--;
    }

    public boolean isDead(){
        return lifespan < 0;
    }

    public void display() {
        if (lifespan > 0) {
            pushStyle();
            stroke(255); 
            strokeWeight(2);
            pushMatrix();
            translate(position.x, position.y);
            rotate(angle);
            line(-length/2, 0, length/2, 0);
            popMatrix();
            popStyle();
        }
    }


    // Set up for public accessors, APIs (Getters/Setters)
    public PVector getPosition(){
        return position.copy();
    }
    public PVector getVelocity(){
        return velocity.copy();
    }
    public float getLength(){
        return length;
    }
    public float getAngle(){
        return angle;
    }
    public float getSpin(){
        return spin;
    }
    public int getLifespan(){
        return lifespan;
    }

    public void setPosition(final PVector position){
        this.position = position;
    }
    public void setVelocity(final PVector velocity){
        this.velocity = velocity;
    }
    public void setLength(final float length){
        this.length = length;
    }
    public void setAngle(final float angle){
        this.angle = angle;
    }
    public void setSpin(final float spin){
        this.spin = spin;
    }
    public void setLifespan(final int lifespan){
        this.lifespan = lifespan;
    }
}

public class AsteroidDebris{
    private PVector position;
    private PVector velocity;
    private float size;
    private int lifespan;
    private int maxLifespan;

    // Default constructor
    public AsteroidDebris(Asteroid asteroid){
        this.position = asteroid.getPosition().copy();
        
       if(asteroid.getAsteroidType() == AsteroidConstants.AsteroidSizeEnum.BIG){
        final float spread = random(-PI/6 , PI/6); //Tight Cone, in direction of laser
        setVelocity(asteroid.getVelocity().normalize().rotate(spread).mult(random(1.0, 2.5)));
        setSize(random(3, 5));
        setMaxLifespan(40);
       } else if(asteroid.getAsteroidType() == AsteroidConstants.AsteroidSizeEnum.MEDIUM){
        final float spread = random(-PI/2 , PI/2); //Loose Cone, in direction of laser
        setVelocity(asteroid.getVelocity().normalize().rotate(spread).mult(random(1.5, 3.5)));
        setSize(random(2, 4));
        setMaxLifespan(30);
       } else {
        //spread is radial no specific direction.
        setVelocity(PVector.random2D().mult(random(2, 5)));
        setSize(random(1, 3));
        setMaxLifespan(20);
       }
       setLifespan(getMaxLifespan());


    }

    public void update(){
        position.add(getVelocity());
        setLifespan(getLifespan() - 1);
    }

    public boolean isDead(){
        return getLifespan() < 0;
    }

    public void display(){
        pushStyle();
        noStroke();

        // fading effect
        final float alpha = map(lifespan, 0, maxLifespan, 0, 255);
        fill(255, 255, 255, alpha);
        ellipse(getPosition().x, getPosition().y, getSize(), getSize());

        popStyle();
    }


    //Public Accessors, APIs (getters/setters)
    public PVector getPosition(){
        return position.copy();
    }
    public PVector getVelocity(){
        return velocity.copy();
    }
    public float getSize(){
        return size;
    }
    public int getLifespan(){
        return lifespan;
    }
    public int getMaxLifespan(){
        return maxLifespan;
    }
    public void setPosition(final PVector position){
        this.position = position;
    }
    public void setVelocity(final PVector velocity){
        this.velocity = velocity;
    }
    public void setSize(final float size){
        this.size = size;
    }
    public void setLifespan(final int lifespan){
        this.lifespan = lifespan;
    }
    public void setMaxLifespan(final int maxLifespan){
        this.maxLifespan = maxLifespan;
    }

}

public class UFODebris extends ShipDebris{

    //Default Constructor
    public UFODebris(final PVector position){
        super(position);
        
    }

    @Override
    public void display() {
        if (lifespan > 0) {
            pushStyle();
            stroke(255);
            strokeWeight(2);
            pushMatrix();
            translate(position.x, position.y);
            rotate(angle);
            line(-length/2, 0, length/2, 0);
            popMatrix();
            popStyle();
        }
    }
}
