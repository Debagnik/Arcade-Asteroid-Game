/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2026 Rak Kingabed <debagnik@debagnik.in>
 * FILE: hud.pde
 */

 import java.io.File;

 public class HUD {
    private PApplet parent;
    private PFont hudFont;
    private Spacecraft dummyShip;
    private static final String CLASSIC_GAME_MODE = "Game Mode: Classic";
    private static final String TIMEBOUND_GAME_MODE = "Game Mode: Time Bound";
    private static final String ENDLESS_GAME_MODE = "Game Mode: Endless";
    private static final String LEVEL = "Level: ";
    private static final String HP_TEXT = "Ship Hull Integrity: ";
    private static final String PERCENT_SYMBOL = " %";
    private static final String TIME_LEFT = "Time Left: ";
    private static final String TIMER_SEPARATOR = " mins : ";
    private static final String SECONDS_SHORTHAND = " secs";


    public HUD(PApplet parent){
        setParent(parent);
        final String fontPath = getParent().dataPath(AsteroidConstants.FONT_PATH);
        try{
            File fontFile = new File(fontPath);
            if(!fontFile.exists()){
                throw new RuntimeException("ERROR: Font file not found at " + fontPath + "\n\nPlease refer to README.md for asset setup instructions.\n\n");
            } else {
                setHudFont(getParent().createFont(fontPath, 64));
            }
        } catch(Exception ex) {
            setHudFont(getParent().createFont("Courier New", 64));
            System.err.println("ERROR: Loading custom font failed\n" + ex.getMessage());
        }
        
        setDummyShip(new Spacecraft(false)); //Slightly smaller ship

    }

    //Draw HUD for Classic Game mode.
    public void displayClassic(int score, int lives, int level, float hp) {
        getParent().pushStyle();
        getParent().textFont(getHudFont());
        getParent().noStroke();
        getParent().fill(255);

        //Display score.
        getParent().textAlign(PConstants.LEFT, PConstants.TOP);
        getParent().textSize(24);
        //Padding 9 zeros to the left.
        String displayScore = PApplet.nf(score, 9);
        getParent().text(displayScore, 20, 20);

        //Display gamemode
        getParent().textAlign(PConstants.CENTER, PConstants.TOP);
        getParent().textSize(20);
        getParent().text(CLASSIC_GAME_MODE, getParent().width/2, 20);

        //Display Levels
        getParent().textAlign(PConstants.RIGHT, PConstants.TOP);
        getParent().textSize(20);
        getParent().text(LEVEL + PApplet.nf(level, 3), getParent().width - 20, 20);

        //Display lives counter
        final float startX = 30;
        final float startY = 60;
        float gap = 25; //Gaps between the icons.

        for(int i = 0; i < lives; i++){
            getParent().pushMatrix();
            getParent().translate(startX + (i * gap), startY);
            getParent().rotate(-PConstants.HALF_PI); //Points ship to up

            //Draw ship
            getDummyShip().drawSpaceShipVisuals(getParent());
            getParent().popMatrix();
        }
        

        //Display HP
        int displayHP = (int) Math.max(0, hp);
        getParent().textAlign(PConstants.LEFT, PConstants.BOTTOM);
        getParent().textSize(20);
        getParent().text(HP_TEXT + displayHP + PERCENT_SYMBOL, 20, getParent().height - 20);

        getParent().popStyle();
    }

    public void displayEndless(int score, int level, float hp) {
        getParent().pushStyle();
        getParent().textFont(getHudFont());
        getParent().noStroke();
        getParent().fill(255);

        //Display score.
        getParent().textAlign(PConstants.LEFT, PConstants.TOP);
        getParent().textSize(24);
        //Padding 9 zeros to the left.
        String displayScore = PApplet.nf(score, 9);
        getParent().text(displayScore, 20, 20);

        //Display gamemode
        getParent().textAlign(PConstants.CENTER, PConstants.TOP);
        getParent().textSize(20);
        getParent().text(ENDLESS_GAME_MODE, getParent().width/2, 20);

        //Display Levels
        getParent().textAlign(PConstants.RIGHT, PConstants.TOP);
        getParent().textSize(20);
        getParent().text(LEVEL + PApplet.nf(level, 3), getParent().width - 20, 20);
        
        //Display HP
        int displayHP = (int) Math.max(0, hp);
        getParent().textAlign(PConstants.LEFT, PConstants.BOTTOM);
        getParent().textSize(20);
        getParent().text(HP_TEXT + displayHP + PERCENT_SYMBOL, 20, getParent().height - 20);

        getParent().popStyle();
    }

    public void displayTimeBound(int score, int timer) {
        getParent().pushStyle();
        getParent().textFont(getHudFont());
        getParent().noStroke();
        getParent().fill(255);

        //Display score.
        getParent().textAlign(PConstants.LEFT, PConstants.TOP);
        getParent().textSize(24);
        //Padding 9 zeros to the left.
        String displayScore = PApplet.nf(score, 9);
        getParent().text(displayScore, 20, 20);

        //Display gamemode
        getParent().textAlign(PConstants.CENTER, PConstants.TOP);
        getParent().textSize(20);
        getParent().text(TIMEBOUND_GAME_MODE, getParent().width/2, 20);

        //Display time left
        getParent().textAlign(PConstants.RIGHT, PConstants.TOP);
        getParent().textSize(20);
        //Logger.log(timer);
        int totalSeconds = Math.max(0, timer) / 60;
        int mins = totalSeconds / 60;
        int secs = totalSeconds % 60;

        getParent().text(TIME_LEFT + PApplet.nf(mins, 2) + TIMER_SEPARATOR + PApplet.nf(secs, 2) + SECONDS_SHORTHAND, getParent().width - 20, 20);

        getParent().popStyle();
    }

    public PApplet getParent(){
        return parent;
    }
    public void setParent(final PApplet parent){
        this.parent = parent;
    }
    public PFont getHudFont(){
        return hudFont;
    }
    public void setHudFont(final PFont hudFont){
        this.hudFont = hudFont;
    }
    public Spacecraft getDummyShip(){
        return dummyShip;
    }
    public void setDummyShip(final Spacecraft dummyShip){
        dummyShip.setSize(AsteroidConstants.SHIP_SIZE * 0.8f);
        this.dummyShip = dummyShip;
    }
 }