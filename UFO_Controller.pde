/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2026 Rak Kingabed <debagnik@debagnik.in>
 * FILE: UFO_Controller.pde
 */

import java.util.HashSet;

public class UFOController{
    private ArrayList<UFO> activeUFOs;
    private ExplosionController fx;

    public UFOController(ExplosionController fx){
        setActiveUFOs(new ArrayList<UFO>());
        setExplosionController(fx);

    }

    private void spawnUFOs(int level){
        if(level < AsteroidConstants.UFO_START_LEVEL){
            return;
        }
        // Flag for multiple UFO spawn
        int limit = AsteroidConstants.ALLOW_MULTIPLE_UFOS ? AsteroidConstants.MAX_UFO_COUNT : 1;
        limit = level > AsteroidConstants.UFO_DUAL_SPAWN_LEVEL ? limit : 1;
        //Logger.log(limit);

        if(activeUFOs.size() >= limit){
            return;
        }

        if(random(1) < AsteroidConstants.UFO_SPAWN_CHANCE){
            AsteroidConstants.UFOTypeEnum ufoType;

            if(level < AsteroidConstants.UFO_DUAL_SPAWN_LEVEL){
                ufoType = AsteroidConstants.UFOTypeEnum.BIG;
            } else {
                ufoType = (random(1) < 0.5) ? AsteroidConstants.UFOTypeEnum.BIG : AsteroidConstants.UFOTypeEnum.SMALL;
            }
            activeUFOs.add(new UFO(ufoType));
        }


    }

    public void update(int level, ArrayList<Asteroid> asteroids, ArrayList<PlayerLaser> playerLasers){
        // spawns UFOs
        spawnUFOs(level);

        final HashSet<UFO> despawnUFOSet = new HashSet<UFO>();
        for(UFO ufo : activeUFOs){
            ufo.update(asteroids);
            ufo.display();
            if(handleUFOCollisions(ufo, playerLasers)){
                getExplosionController().animateUFOExplosion(ufo);
                despawnUFOSet.add(ufo);
            }
        }
        activeUFOs.removeAll(despawnUFOSet);

    }

    public void despawnUFO(UFO ufo){
        activeUFOs.remove(ufo);
    }

    private boolean handleUFOCollisions(UFO ufo, ArrayList<PlayerLaser> playerLasers){
        for(PlayerLaser pl : playerLasers){
            if (!pl.isActive()){
                continue;
            }
            if(PhysicsHelper.checkPlayerLaser2UFOCollision(pl, ufo)){
                pl.setActive(false);
                return true;
            }
        }
        return false;
    }

    public void setActiveUFOs(ArrayList<UFO> activeUFOs){
        this.activeUFOs = (activeUFOs == null) ? new ArrayList<UFO>() : activeUFOs;
    }
    public void setExplosionController(ExplosionController fx){
        if (fx == null){
            throw new IllegalArgumentException("ExplosionController is required");
        }
        this.fx = fx;
    }
    public ExplosionController getExplosionController(){
        return fx;
    }
    public ArrayList<UFO> getActiveUFOs(){
        return activeUFOs;
    }


}