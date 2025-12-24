/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: DebrisAnimation.pde
 */

public class Debris{
    private PVector position;
    private PVector velocity;
    private float length;
    private float angle;
    private float spin;
    private Integer lifespan;

    //Default Constructor
    public Debris(final PVector position){
        this.position = position.copy();
        velocity = PVector.random2D();
        velocity.mult(random(1, 3));

        length = random(5, 15);
        angle = random(AsteroidConstants.TWO_PI);
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


    // Set up for buplic accessors, APIs (Getters/Setters)
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
    public Integer getLifespan(){
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
    public void setLifespan(final Integer lifespan){
        this.lifespan = lifespan;
    }
}
