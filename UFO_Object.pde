/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2026 Rak Kingabed <debagnik@debagnik.in>
 * FILE:UFO_Object.pde
 */

 import java.util.HashSet;

public class UFO {
  // UFO Global attributes
  private PVector position;
  private PVector velocity;
  private PVector targetWaypoint;
  private AsteroidConstants.UFOTypeEnum type;
  private float size;
  private float speed;
  private float damageOutput;
  private int fireTimer;

  private ArrayList<EnemyLaser> ufoLasers;
  private final HashSet<EnemyLaser> lasersToRemove = new HashSet<EnemyLaser>();

  // Default Constructor
  public UFO(AsteroidConstants.UFOTypeEnum type) {
    setType(type);
    setUFOLasers(new ArrayList<EnemyLaser>());

    if (AsteroidConstants.UFOTypeEnum.BIG == type) {
      setSize(AsteroidConstants.UFO_SIZE_BIG);
      setSpeed(AsteroidConstants.UFO_SPEED_BIG);
      setDamageOutput(AsteroidConstants.DAMAGE_BIG_UFO);
    } else {
      setSize(AsteroidConstants.UFO_SIZE_SMALL);
      setSpeed(AsteroidConstants.UFO_SPEED_SMALL);
      setDamageOutput(AsteroidConstants.DAMAGE_SMALL_UFO);
    }

    // Random spawn on the edge of the playable area
    if (random(1) < 0.5) {
      setPosition(new PVector((random(1) < 0.5 ? 0 : width), random(height)));
    } else {
      setPosition(new PVector(random(width), (random(1) < 0.5 ? 0 : height)));
    }

    pickNewWaypoint(); // Pick next moving direction
    setFireTimer((int)AsteroidConstants.UFO_FIRE_RATE);
  }

  private void pickNewWaypoint() {
    setTargetWaypoint(new PVector(random(width), random(height)));
  }

  public void update(ArrayList<Asteroid> asteroids) {
    // seek desired waypoint.
    PVector toWayPoint = PVector.sub(getTargetWaypoint(), getPosition());
    PVector desired;
    if (toWayPoint.mag() > 0) {
      desired = toWayPoint.normalize().mult(getSpeed());
    } else {
      desired = new PVector(0, 0);
      pickNewWaypoint(); // Pick new waypoint if we're exactly at target
    }

    // Obstacle Avoidance (Using PhysicsHelper)
    PVector avoidance = PhysicsHelper.avoidAsteroidForUFO(getPosition(), asteroids);

    // Apply velocity Vector
    setVelocity(desired.add(avoidance));
    velocity.limit(getSpeed());
    position.add(velocity);

    // Pick new waypoint
    if (PVector.dist(getPosition(), getTargetWaypoint()) < 10) {
      pickNewWaypoint();
    }

    // Same ol' screen wrapping logic
    PhysicsHelper.screenWrap(position, size, width, height);

    handleFiring();
  }

  private void handleFiring() {
    setFireTimer(getFireTimer() - 1);
    if (getFireTimer() <= 0) {
      float randomAngle = random(TWO_PI);
      //Spawns Enemy Laser at random angle.
      getUFOLasers().add(new EnemyLaser(getPosition(), randomAngle, getDamageOutput()));
      setFireTimer((int)AsteroidConstants.UFO_FIRE_RATE);
    }

    lasersToRemove.clear();
    for (EnemyLaser el : getUFOLasers()) {
      el.update();
      if (!el.isActive()) {
        lasersToRemove.add(el);
      }
    }
    getUFOLasers().removeAll(lasersToRemove);
  }

  public void display() {
    pushStyle();
    fill(0);
    stroke(255);
    strokeWeight(2);
    pushMatrix();
    translate(getPosition().x, getPosition().y);
    // Scale drawing based on size
    float r = getSize() / 2.0; 
    noFill();
    beginShape();
    vertex(-r, 0);
    vertex(-r * 0.4, -r * 0.35);
    vertex(r * 0.4, -r * 0.35);
    vertex(r, 0);
    vertex(r * 0.4, r * 0.35);
    vertex(-r * 0.4, r * 0.35);
    endShape(CLOSE);

    line(-r, 0, r, 0);

    float deckY = -r * 0.35;
    float domeW = r * 0.35;
    float domeH = r * 0.35;
    beginShape();
    for (int i = 0; i <= 8; i++) {
      float angle = map(i, 0, 8, PI, TWO_PI);
      float x = cos(angle) * domeW;
      float y = deckY + (sin(angle) * domeH); 
      vertex(x, y);
    }
    endShape();
    
    popMatrix();
    popStyle();
    // renders UFO Lasers
    for (EnemyLaser el : getUFOLasers()) {
      el.display();
    }
  }



  public float getRadius() {
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

  public ArrayList<EnemyLaser> getUFOLasers() {
    return ufoLasers;
  }

  public void setUFOLasers(ArrayList<EnemyLaser> ufoLasers) {
    this.ufoLasers = ufoLasers;
  }
}
