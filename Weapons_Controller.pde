/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Weapons_Controller.pde
 */

public class WeaponsController{
    private ArrayList<PlayerLaser> playerLasers;

    // Default Constructor
    public WeaponsController(){
        playerLasers = new ArrayList<PlayerLaser>();
    }

    public void fire(Spacecraft ship, int playerLevel){
        playerLasers.add(new PlayerLaser(ship.getPosition(), ship.getHeading(), playerLevel));
    }

    // Core Weapon display logic
    public void displayAndUpdate(){
        // looping to remove dead lasers
        for(PlayerLaser l : playerLasers){
            l.update();
            l.display();
        }
        playerLasers.removeIf(l -> !l.isActive());
    }

    // Generic Getter
    public ArrayList<PlayerLaser> getPlayerLasers(){
        // Returning the Laser List in a new List (Defensive Programming).
        return new ArrayList<PlayerLaser>(playerLasers);
    }
     
}