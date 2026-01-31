/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Weapons_Controller.pde
 */
import java.util.HashSet;

public class WeaponsController{
    private ArrayList<PlayerLaser> playerLasers;
    private HashSet<PlayerLaser> dedPlayerLasers = new HashSet<PlayerLaser>();

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
        dedPlayerLasers.clear();
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
        return playerLasers;
    }
     
}