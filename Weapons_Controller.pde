public class WeaponsController{
    ArrayList<Laser> lasers;

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
        return lasers;
    }
     
}