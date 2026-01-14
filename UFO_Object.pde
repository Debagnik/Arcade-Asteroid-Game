/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2026 Rak Kingabed <debagnik@debagnik.in>
 * FILE:
 */

import java.util.HashSet;

public class UFO{
    // UFO Global attributes
    private PVector position;
    private PVector velocity;
    private PVector targetWaypoint;
    private AsteroidConstants.UFOTypeEnum type;
    private float size;
    private float speed;
    private float damageOutput;
    private int fireTimer;

    private ArrayList<EnemyLaser> ufoLaser;

    // Default Constructor
    public UFO(AsteroidConstants.UFOTypeEnum type){
        setType(type);
        setUfoLaser(new ArrayList<EnemyLaser>());

        if(AsteroidConstants.UFOTypeEnum.BIG == type){
            setSize(AsteroidConstants.UFO_SIZE_BIG);
            setSpeed(AsteroidConstants.UFO_SPEED_BIG);
            setDamageOutput(AsteroidConstants.DAMAGE_BIG_UFO);
        } else { 
            setSize(AsteroidConstants.UFO_SIZE_SMALL);
            setSpeed(AsteroidConstants.UFO_SPEED_SMALL);
            setDamageOutput(AsteroidConstants.DAMAGE_SMALL_UFO);
        }

        // Random spawn on the edge of the playable area
        if(random(1) < 0.5){
            setPosition(new PVector((random(1) < 0.5 ? 0 : width), random(height)));
        } else {
            setPosition(new PVector(random(width), (random(1) < 0.5 ? 0 : height)));
        }

        pickNewWaypoint(); // Pick next moving direction
        setFireTimer((int)AsteroidConstants.UFO_FIRE_RATE);

    }

    private void pickNewWaypoint(){
        setTargetWaypoint(new PVector(random(width), random(height)));
    }

    public void update(ArrayList<Asteroid> asteroids){
        // seek desired waypoint.
        PVector desired = PVector.sub(getTargetWaypoint(), getPosition()).normalize().mult(getSpeed());

        // Obstacle Avoidance (Using PhysicsHelper)
        PVector avoidance = PhysicsHelper.avoidAsteroidForUFO(getPosition(), asteroids);

        // Apply velocity Vector
        setVelocity(desired.add(avoidance));
        velocity.limit(getSpeed());
        position.add(velocity);

        // Pick new waypoint
        if (PVector.dist(getPosition(), getTargetWaypoint()) < 10){
            pickNewWaypoint();
        }

        // Same ol' screen wrapping logic
        PhysicsHelper.screenWrap(getPosition(), getSize(), width, height);

        handleFiring();


    }

    private void handleFiring(){
        setFireTimer(getFireTimer() - 1);
        if (getFireTimer() <= 0) {
            float randomAngle = random(TWO_PI);
            //Spawns Enemy Laser at random angle.
            ufoLaser.add(new EnemyLaser(getPosition(), randomAngle, getDamageOutput()));
            fireTimer = (int)AsteroidConstants.UFO_FIRE_RATE;
        }

        final HashSet<EnemyLaser> lasersToRemove = new HashSet<EnemyLaser>();
        for(EnemyLaser el : ufoLaser){
            el.display();
            el.update();
            if(!el.isActive()){
                lasersToRemove.add(el);
            }
        }
        ufoLaser.removeAll(lasersToRemove);
    }

    public void display() {
        pushStyle();
        fill(0);
        stroke(0, 255, 0); // UFO is green in color
        strokeWeight(2);
        pushMatrix();
        translate(getPosition().x, getPosition().y);
        // Scale drawing based on size
        float s = getSize();
        ellipse(0, 0, s, s * 0.4); 
        arc(0, -s * 0.1, s * 0.5, s * 0.4, -PI, 0); 
        popMatrix();
        popStyle();
    }



    public float getRadius(){
        return this.size / 2.0;
    }

    // APIs and Accessors (Getter and setters)
    public PVector getPosition() {
        return position.copy();
    }

    public void setPosition(PVector position) {
        this.position = position;
    }

    public PVector getVelocity() {
        return velocity.copy();
    }

    public void setVelocity(PVector velocity) {
        this.velocity = velocity;
    }

    public PVector getTargetWaypoint() {
        return targetWaypoint.copy();
    }

    public void setTargetWaypoint(PVector targetWaypoint) {
        this.targetWaypoint = targetWaypoint;
    }

    public AsteroidConstants.UFOTypeEnum getType() {
        return type;
    }

    public void setType(AsteroidConstants.UFOTypeEnum type) {
        this.type = type;
    }

    public float getSize() {
        return size;
    }

    public void setSize(float size) {
        this.size = size;
    }

    public float getSpeed() {
        return speed;
    }

    public void setSpeed(float speed) {
        this.speed = speed;
    }

    public float getDamageOutput() {
        return damageOutput;
    }

    public void setDamageOutput(float damageOutput) {
        this.damageOutput = damageOutput;
    }

    public int getFireTimer() {
        return fireTimer;
    }

    public void setFireTimer(int fireTimer) {
        this.fireTimer = fireTimer;
    }

    public ArrayList<EnemyLaser> getUfoLaser() {
        return ufoLaser;
    }

    public void setUfoLaser(ArrayList<EnemyLaser> ufoLaser) {
        this.ufoLaser = ufoLaser;
    }

}