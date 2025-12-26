/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Explosion_Controller.pde
 */


import java.util.HashSet;
import java.util.ArrayList;

// Main Explosion controller
public class ExplosionController{
    private AsteroidExplosionFacade asteroidExplosionFacade;
    private ShipExplosionFacade shipExplosionFacade;

    // default controller constructor
    public ExplosionController(){
        asteroidExplosionFacade = new AsteroidExplosionFacade();
        shipExplosionFacade = new ShipExplosionFacade();
    }

    // Delegates Animation for Asteroid Explosion.
    public void animateAsteroidExplosion(Asteroid a){
        asteroidExplosionFacade.animateAsteroidExplosions(a);
    }

    public void animateShipExplosion(Spacecraft ship){
        shipExplosionFacade.animateShipExplosion(ship);
    }

    public void displayAndUpdate(){
        asteroidExplosionFacade.updateAndDisplay();
        shipExplosionFacade.updateAndDisplay();
    }

    public void reset(){
        shipExplosionFacade.reset();
        asteroidExplosionFacade.reset();
    }



}

// Asteroid Explosion Facade
private class AsteroidExplosionFacade {
    private ArrayList<AsteroidDebris> asteroidDebrisList;

    //default constructor
    public AsteroidExplosionFacade(){
        asteroidDebrisList = new ArrayList<AsteroidDebris>();
    }

    public void animateAsteroidExplosions(Asteroid asteroid){
        int particleCount = 0;

        switch(asteroid.getExplosionType()){
            case BIG_EXPLOSION:
                particleCount = AsteroidConstants.PARTICLE_COUNT_BIG;
                break;
            case MEDIUM_EXPLOSION:
                particleCount = AsteroidConstants.PARTICLE_COUNT_MEDIUM;
                break;
            case SMALL_EXPLOSION:
                particleCount = AsteroidConstants.PARTICLE_COUNT_SMALL;
                break;
            default:
                System.err.println("WARNING: Unexpected explosion type: " + asteroid.getExplosionType());
                break;
        }

        for(int i = 0; i < particleCount; i++){
            asteroidDebrisList.add(new AsteroidDebris(asteroid));
        }
    }

    public void updateAndDisplay(){
        HashSet<AsteroidDebris> despawnDebrisSet = new HashSet<AsteroidDebris>();
        for(AsteroidDebris ad : asteroidDebrisList){
            ad.update();
            ad.display();
            if(ad.isDead()){
                despawnDebrisSet.add(ad);
            }
        }
        asteroidDebrisList.removeAll(despawnDebrisSet);
    }

    public void reset(){
        asteroidDebrisList.clear();
    }
}

// Ship Explosion Facade
private class ShipExplosionFacade{
    private ArrayList<ShipDebris> shipDebrisList;
    private final int SHIP_WRECKAGE_PARTS = 4;

    // Default Constructor
    public ShipExplosionFacade(){
        shipDebrisList = new ArrayList<ShipDebris>();
    }

    public void animateShipExplosion(Spacecraft ship){
        for(int i = 0; i < SHIP_WRECKAGE_PARTS; i++){
            shipDebrisList.add(new ShipDebris(ship.getPosition()));
        }
    }

    public void updateAndDisplay(){
        final HashSet<ShipDebris> despawnShipDebrisSet = new HashSet<ShipDebris>();
        
        for(ShipDebris sd : shipDebrisList){
            sd.update();
            sd.display();
            if(sd.isDead()){
                despawnShipDebrisSet.add(sd);
            }
        }
        shipDebrisList.removeAll(despawnShipDebrisSet);
    }

    public void reset(){
        shipDebrisList.clear();
    }


}