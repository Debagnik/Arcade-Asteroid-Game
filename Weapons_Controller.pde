/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Weapons_Controller.pde
 */

public class WeaponsController{
    private ArrayList<Laser> lasers;

    // Default Constructor
    public WeaponsController(){
        lasers = new ArrayList<Laser>();
    }

    public void fire(Spacecraft ship){
        lasers.add(new Laser(ship.position, ship.heading));
        //println("FIRE! Total Lasers: " + lasers.size());
    }

    // Core Weapon display logic
    public void displayAndUpdate(){
        // looping backwards to remove dead lasers
        for(Laser l : lasers){
            l.update();
            l.display();
        }
        lasers.removeIf(l -> !l.active);
    }

    // Generic Getter
    public ArrayList<Laser> getLasers(){
        // Returning the Laser List in a new List (Defensive Programming).
        return new ArrayList<Laser>(lasers);
    }
     
}