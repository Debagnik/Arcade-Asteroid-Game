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
    private UFOExplosionFacade ufoExplosionFacade;

    // default controller constructor
    public ExplosionController(){
        asteroidExplosionFacade = new AsteroidExplosionFacade();
        shipExplosionFacade = new ShipExplosionFacade();
        ufoExplosionFacade = new UFOExplosionFacade();
    }

    // Delegates Animation for Asteroid Explosion.
    public void animateAsteroidExplosion(Asteroid a){
        asteroidExplosionFacade.animateAsteroidExplosions(a);
    }

    public void animateShipExplosion(Spacecraft ship){
        shipExplosionFacade.animateShipExplosion(ship);
    }

    public void animateUFOExplosion(UFO ufo){
        ufoExplosionFacade.animateUFOExplosion(ufo);
    }

    public void displayAndUpdate(){
        asteroidExplosionFacade.updateAndDisplay();
        shipExplosionFacade.updateAndDisplay();
        ufoExplosionFacade.updateAndDisplay();
    }

    public void reset(){
        shipExplosionFacade.reset();
        asteroidExplosionFacade.reset();
        ufoExplosionFacade.reset();
    }



}

// Asteroid Explosion Facade
private class AsteroidExplosionFacade {
    private ArrayList<AsteroidDebris> asteroidDebrisList;
    private HashSet<AsteroidDebris> despawnDebrisSet = new HashSet<AsteroidDebris>();

    //default constructor
    public AsteroidExplosionFacade(){
        asteroidDebrisList = new ArrayList<AsteroidDebris>();
    }

    public void animateAsteroidExplosions(Asteroid asteroid){
        int particleCount = 0;

        switch(asteroid.getAsteroidType()){
            case BIG:
                particleCount = AsteroidConstants.PARTICLE_COUNT_BIG;
                break;
            case MEDIUM:
                particleCount = AsteroidConstants.PARTICLE_COUNT_MEDIUM;
                break;
            case SMALL:
                particleCount = AsteroidConstants.PARTICLE_COUNT_SMALL;
                break;
            default:
                System.err.println("WARNING: Unexpected explosion type: " + asteroid.getAsteroidType());
                break;
        }

        for(int i = 0; i < particleCount; i++){
            asteroidDebrisList.add(new AsteroidDebris(asteroid));
        }
    }

    public void updateAndDisplay(){
        despawnDebrisSet.clear();
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
    private final HashSet<ShipDebris> despawnShipDebrisSet = new HashSet<ShipDebris>();

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
        despawnShipDebrisSet.clear();
        
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

// UFO Explosion Facade
private class UFOExplosionFacade{

    private final int UFO_WRECKAGE_PARTS = 8;
    private final HashSet<UFODebris> despawnUFODebrisSet = new HashSet<UFODebris>();
    private ArrayList<UFODebris> ufoDebrisList;

    public UFOExplosionFacade(){
        setUfoDebrisList(new ArrayList<UFODebris>());
    }

    public void animateUFOExplosion(UFO ufo){
        // Debris spawning and animation
        for(int i = 0; i < UFO_WRECKAGE_PARTS; i++){
            ufoDebrisList.add(new UFODebris(ufo.getPosition()));
        }
    }

    public void reset(){
        ufoDebrisList.clear();
    }

    public void updateAndDisplay(){
        despawnUFODebrisSet.clear();

        for(UFODebris ud : getUfoDebrisList()){
            ud.update();
            ud.display();
            if(ud.isDead()){
                despawnUFODebrisSet.add(ud);
            }
        }
        
        ufoDebrisList.removeAll(despawnUFODebrisSet);
    }


    public void setUfoDebrisList(ArrayList<UFODebris> ufoDebrisList){
        this.ufoDebrisList = ufoDebrisList;
    }
    public ArrayList<UFODebris> getUfoDebrisList(){
        return ufoDebrisList;
    }
}