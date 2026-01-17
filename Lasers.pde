/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Lasers.pde
 */

// base class
public abstract class Laser {
  private PVector position;
  private PVector velocity;
  private int ttl;
  private boolean active;

  //Default Constructor
  public Laser(PVector origin, float angle, float speed, int ttl) {
    this.position = origin.copy();


    // Calculate Velocity
    // It moves in the direction of the angle, but faster than the ship
    velocity = PVector.fromAngle(angle).mult(speed);

    this.ttl = ttl;

    this.active = true;
  }

  public void update() {
    position.add(velocity);

    // Screen Wrap
    PhysicsHelper.screenWrap(position, 1.0, width, height);

    // Decrease TTL
    ttl--;
    if (ttl < 0) {
      active = false;
    }
  }

  public abstract void display();

  // Generic Class APIs (Getter/Setter)
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

  public int getTTL() {
    return ttl;
  }

  public void setTTL(int ttl) {
    this.ttl = ttl;
  }

  public boolean isActive() {
    return active;
  }

  public void setActive(boolean active) {
    this.active = active;
  }
}

// Player Laser Inherits the Base (Stroke = white)
public class PlayerLaser extends Laser {
  // Default Constructor
  public PlayerLaser(PVector shipPos, float angle, int playerLevel) {
    // Calculate nose position logic
    super(
      new PVector(
      shipPos.x + (AsteroidConstants.SHIP_SIZE * cos(angle)),
      shipPos.y + (AsteroidConstants.SHIP_SIZE * sin(angle))
      ),
      angle,
      AsteroidConstants.LASER_SPEED,
      // This line increses the laser ttl in a logarithmic scale 
      (int)ceil(AsteroidConstants.LASER_LIFESPAN + 10.0 * log(playerLevel))
      );
  }


    @Override
    public void display() {
        pushStyle();
        stroke(255); //white lasers
        strokeWeight(2);
        ellipse(super.getPosition().x, super.getPosition().y, AsteroidConstants.LASER_SIZE, AsteroidConstants.LASER_SIZE);
        popStyle();
    }
}

// Enemy Laser Class deals damage to player, Stroke(RED)
public class EnemyLaser extends Laser {
  private float damage;

  public EnemyLaser(PVector origin, float angle, float damage) {
    super(origin, angle, AsteroidConstants.LASER_SPEED, AsteroidConstants.LASER_LIFESPAN + 30);
    setDamage(damage);
  }

  @Override
    public void display() {
    pushStyle();
    stroke(255, 0, 0);
    strokeWeight(3);
    ellipse(super.getPosition().x, super.getPosition().y, AsteroidConstants.LASER_SIZE, AsteroidConstants.LASER_SIZE);
    popStyle();
  }


  //General Public APIs (Getters/Setters)
  public float getDamage() {
    return damage;
  }
  public void setDamage(final float damage) {
    this.damage = damage;
  }
}
