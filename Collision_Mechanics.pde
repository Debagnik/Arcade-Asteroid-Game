/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Collision_Mechanics.pde
 */

public class CollisionMechanics {

  public void checkPlayerCollision() {
    // Asteroid vs PlayerShip Collision
    HashSet<Asteroid> spawnChildAsteroids = new HashSet<Asteroid>();
    HashSet<Asteroid> despawnParentAsteroids = new HashSet<Asteroid>();
    for (Asteroid a : asteroids) {
      final boolean hit = PhysicsHelper.checkShip2AsteroidCollision(ship, a);
      if (hit) {
        explosions.animateAsteroidExplosion(a);
        despawnParentAsteroids.add(a);
        float shipHullDamage = getShipHullDamage(a);
        if (a.getRadius() > AsteroidConstants.MIN_ASTEROID_SIZE) {
          spawnChildAsteroids.add(new Asteroid(a.getPosition(), a.getRadius()/2.0));
          spawnChildAsteroids.add(new Asteroid(a.getPosition(), a.getRadius()/2.0));
        }

        boolean isDed = ship.takeDamage(shipHullDamage);
        if(isDed){
          playerController.animateShipDestroy(ship);
          break;
        }
        
        
      }
    }
    asteroids.removeAll(despawnParentAsteroids);
    asteroids.addAll(spawnChildAsteroids);
  }

  private float getShipHullDamage(Asteroid a){
    float damage = 0;

    switch(a.getAsteroidType()){
      case BIG:
        damage = AsteroidConstants.PLAYER_MAX_HP; //Insta kill
        break;
      case MEDIUM:
        damage = 30f;
        break;
      case SMALL:
        damage = 5f;
        break;
      default:
        damage = 50f; // Author being an asshole, if player ever goes into this case then they deserve this punishment.
        break;
    }

    return damage;

  }

  // Asteroid Collision mechanics
  public void asteroidsMechanics() {
    for (Asteroid a : asteroids) {
      a.update();
      a.display();
    }

    // LASER VS ASTEROID COLLISION
    // Get all active lasers
    ArrayList<PlayerLaser> activeLasers = weapon.getPlayerLasers();
    HashSet<Asteroid> spawnChildAsteroids = new HashSet<Asteroid>();
    HashSet<Asteroid> despawnParentAsteroids = new HashSet<Asteroid>();
    HashSet<PlayerLaser> deactivateLasers = new HashSet<PlayerLaser>();

    for (PlayerLaser l : activeLasers) {
      // Optimization: If this laser is already marked inactive (e.g. somehow hit twice), skip it
      if (!l.isActive() || deactivateLasers.contains(l)) {
        continue;
      }
      //Logger.log(l, getLevel());

      for (Asteroid a : asteroids) {
        // Optimization: If asteroid is already destroyed by another laser in this frame, skip it
        if (despawnParentAsteroids.contains(a)) {
          continue;
        }
        //Logger.log(a, getLevel());

        // Check Hit collision
        if (PhysicsHelper.checkLaserCollision(l, a)) {
          explosions.animateAsteroidExplosion(a); //Asteroid explosion Animation

          if (a.getRadius() > AsteroidConstants.MIN_ASTEROID_SIZE) {
            // Asteroid Split logic and spawning logic
            spawnChildAsteroids.add(new Asteroid(a.getPosition(), (a.getRadius())/2.0));
            spawnChildAsteroids.add(new Asteroid(a.getPosition(), (a.getRadius())/2.0));
          }
          despawnParentAsteroids.add(a);
          deactivateLasers.add(l);
          break; // Stops checking this Laser
        }
      }
    }

    // Safely add/remove child/parent asteroids
    asteroids.removeAll(despawnParentAsteroids);
    asteroids.addAll(spawnChildAsteroids);

    // Safely deactivate Lasers
    for (PlayerLaser l : deactivateLasers) {
      l.setActive(false);
    }

    // Asteroid Vs Asteroid Collision Mechanics
    //check for collision mechanics on game loop
    for (int i = 0; i < asteroids.size(); ++i) {
      for (int j = i + 1; j < asteroids.size(); ++j) {
        Asteroid a1 = asteroids.get(i);
        Asteroid a2 = asteroids.get(j);

        //Logger.log(a1, getLevel());
        //Logger.log(a2, getLevel());
        //perform collistion detection
        PhysicsHelper.checkCollision(a1, a2);
      }
    }

    //Logger.log(ship, getLevel());
    //Logger.log(weapon, getLevel());

    // Level Up and infinite gameplay logic
    if (asteroids.size() == 0) {
      setLevel(getLevel() + 1);
      for (int i = 0; i < AsteroidConstants.INITIAL_ASTEROID_COUNT; i++) {
        asteroids.add(new Asteroid(ship, AsteroidConstants.ASTEROID_SHIP_SAFE_DISTANCE));
      }
    }
  }

  public void checkUFOAttacksOnPlayer() {
    ArrayList<UFO> activeUFOs = ufoController.getActiveUFOs();
    for (int i = activeUFOs.size() - 1; i >= 0; i--) {
      UFO ufo = activeUFOs.get(i);
      // If UFO wants a suicide route.
      float distBody = PVector.dist(ship.getPosition(), ufo.getPosition());
      if (distBody < (ufo.getRadius() + AsteroidConstants.SHIP_SIZE)) {
        if (ship.takeDamage(AsteroidConstants.PLAYER_MAX_HP)) {
          playerController.animateShipDestroy(ship);
        }
        explosions.animateUFOExplosion(ufo);
        ufoController.despawnUFO(ufo);
        continue;
        //Logger.log(ship);
        //Logger.log(ufo);
      }

      // If UFO laser hits ship.
      for (EnemyLaser el : ufo.getUFOLasers()) {
        if (!el.isActive()) {
          continue;
        }
        float distLaser = PVector.dist(ship.getPosition(), el.getPosition());
        //Collision check
        if (distLaser < (AsteroidConstants.SHIP_SIZE + (AsteroidConstants.LASER_SIZE / 2.0))) {
          // Deals with Ship Damage
          boolean isDed = ship.takeDamage(el.getDamage());
          el.setActive(false);

          if (isDed) {
            playerController.animateShipDestroy(ship);
            break;
          }
        }
      }
    }
  }
}
