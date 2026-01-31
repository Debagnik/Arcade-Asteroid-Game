/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Weapons_Controller.pde
 */
import java.util.HashSet;

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
        HashSet<PlayerLaser> dedPlayerLasers = new HashSet<PlayerLaser>();
        for(PlayerLaser l : playerLasers){
            l.update();
            l.display();
            if(!l.isActive()){
                dedPlayerLasers.add(l);
            }
        }
        playerLasers.removeAll(dedPlayerLasers);
    }

    // Generic Getter
    public ArrayList<PlayerLaser> getPlayerLasers(){
        // Returning the Laser List in a new List (Defensive Programming).
        return playerLasers;
    }
     
}