/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2026 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Title_Screen.pde
 */

import java.io.File;

public class TitleScreen{

    private PApplet parent;
    private PFont tFont;
    private PFont mFont;
    private String[] credits;
    private float creditsY;

    // Default Constructor
    public TitleScreen(PApplet parent){
        setParent(parent);
        final String fontPath = getParent().dataPath("assets/fonts/Orbitron.ttf");
        File fontFile = new File(fontPath);
        if(!fontFile.exists()){
            throw new RuntimeException("ERROR: Font file not found at " + fontPath);
        }

        try{
            setTFont(getParent().createFont(fontPath, 64));
            setMFont(getParent().createFont(fontPath, 64));
        } catch(Exception ex) {
            throw new RuntimeException("ERROR: Could not load font format: " + ex.getMessage());
        }

        try{
            loadCredits();
        } catch (Exception ex){
            throw new RuntimeException("ERROR: Could't load Credits file, Find More Info in the stacktrace \n" + ex.getMessage());
        }


    }

    private void loadCredits(){
        String creditsPath = "assets/data/credits/credits.txt";
        setCredits(getParent().loadStrings(creditsPath));
        if (Objects.isNull(getCredits())){
            System.err.println("ERROR: Credits file not found at " + creditsPath);
            setCredits(new String[]{"CREDITS", "Created by Rak Kingabed", "Credits File Missing"});
        }

        setCreditsY(getParent().height);
    }

    public void display(AsteroidConstants.GameState currentState, ArrayList<Asteroid> backgroundAsteroids){
        for (Asteroid a : backgroundAsteroids) {
            a.update();
            a.display();
        }

        getParent().textAlign(PConstants.CENTER, PConstants.CENTER);
        getParent().noStroke();

        switch(currentState){
            case MENU_MAIN:
                drawMainMenu();
                break;
            case MENU_GAME_SELECT:
                drawGameModeSelect();
                break;
            case MENU_HIGH_SCORE:
                drawHighScores();
                break;
            case MENU_CREDITS:
                drawCredits();
                break;
            case MENU_EXIT:
                gameExit();
                break;
            default:
                throw new RuntimeException("ERROR: Something went wrong in user selecting menu items");
        }

    }

    /* AUTHOR`S NOTE — READ AND OBEY:
     * These numbers were obtained through forbidden means.
     * They are the culmination of arcane rituals performed at ungodly hours,
     * powered by dark magic, handwritten sigils, and the symbolic sacrifice
     * of a perfectly sane human mind (mine).
     * Do NOT ask how they were derived.
     * Do NOT attempt to reproduce the ritual.
     * Altering these values may undo the binding circle,
     * resurrect long-dead bugs, or demand further sacrifices.
     * You have been warned.
     */
    private void drawMainMenu(){
        getParent().textFont(getTFont());
        getParent().fill(255);
        getParent().textSize(getParent().width/10);
        getParent().text("ASTERIODS", getParent().width/2, getParent().height/4.05);

        getParent().textFont(getMFont());
        
        drawButton("NEW GAME", getParent().width/2, getParent().height/2.03, getParent().width/20);
        drawButton("HIGH SCORE", getParent().width/2, getParent().height/1.74, getParent().width/20);
        drawButton("CREDITS", getParent().width/2, getParent().height/1.52, getParent().width/20);
        drawButton("EXIT GAME", getParent().width/2, getParent().height/1.35, getParent().width/20);
    }

    /* AUTHOR`S NOTE — READ AND OBEY:
     * These numbers were obtained through forbidden means.
     * They are the culmination of arcane rituals performed at ungodly hours,
     * powered by dark magic, handwritten sigils, and the symbolic sacrifice
     * of a perfectly sane human mind (mine).
     * Do NOT ask how they were derived.
     * Do NOT attempt to reproduce the ritual.
     * Altering these values may undo the binding circle,
     * resurrect long-dead bugs, or demand further sacrifices.
     * You have been warned.
     */
    private void drawButton(String label, float x, float y, float size) {
        getParent().textSize(size);
        if(isMouseOver(x, y, 200, 30)){
            getParent().fill(255);
            getParent().text("> " + label + " <", x, y);
        } else {
            getParent().fill(200);
            getParent().text(label, x, y);
        }
    }

    private boolean isMouseOver(float x, float y, float w, float h) {
        return getParent().mouseX > x - w/1.5 && getParent().mouseX < x + w/1.5 && getParent().mouseY > y - h/1.5 && getParent().mouseY < y + h/1.5;
    }

    /* AUTHOR`S NOTE — READ AND OBEY:
     * These numbers were obtained through forbidden means.
     * They are the culmination of arcane rituals performed at ungodly hours,
     * powered by dark magic, handwritten sigils, and the symbolic sacrifice
     * of a perfectly sane human mind (mine).
     * Do NOT ask how they were derived.
     * Do NOT attempt to reproduce the ritual.
     * Altering these values may undo the binding circle,
     * resurrect long-dead bugs, or demand further sacrifices.
     * You have been warned.
     */
    private void drawGameModeSelect() {
        getParent().textFont(getTFont());
        getParent().textSize(getParent().width/10);
        getParent().text("ASTERIODS", getParent().width/2, getParent().height/4.05);

        getParent().textSize(getParent().width/15);
        getParent().text("SELECT GAME TYPE", getParent().width/2, getParent().height/2.70);

        getParent().textFont(getMFont());
        drawButton("CLASSIC", getParent().width/2, getParent().height/2.03, getParent().width/20);
        drawButton("ENDLESS", getParent().width/2, getParent().height/1.74, getParent().width/20);
        drawButton("TIME BOUND", getParent().width/2, getParent().height/1.52, getParent().width/20);
        drawButton("MAIN MENU", getParent().width/2, getParent().height/1.35, getParent().width/20);
        drawButton("EXIT GAME", getParent().width/2, getParent().height/1.22, getParent().width/20);
    }


    /* AUTHOR`S NOTE — READ AND OBEY:
     * These numbers were obtained through forbidden means.
     * They are the culmination of arcane rituals performed at ungodly hours,
     * powered by dark magic, handwritten sigils, and the symbolic sacrifice
     * of a perfectly sane human mind (mine).
     * Do NOT ask how they were derived.
     * Do NOT attempt to reproduce the ritual.
     * Altering these values may undo the binding circle,
     * resurrect long-dead bugs, or demand further sacrifices.
     * You have been warned.
     */
    private void drawHighScores() {
        getParent().textFont(tFont);
        getParent().textSize(getParent().width/10);
        getParent().text("ASTERIODS", getParent().width/2, getParent().height/4.05);

        getParent().textSize(getParent().width/15);
        getParent().text("GLOBAL HIGHSCORE", getParent().width/2, getParent().height/2.70);

        getParent().textFont(getMFont());
        getParent().textSize(getParent().width/20);
        getParent().text("WORK IN PROGRESS", getParent().width/20, getParent().height/2.21);


        getParent().textSize(18);
        drawButton("MAIN MENU", getParent().width/2, getParent().height/1.35f, getParent().width/20);

    }


    
    private void drawCredits() {
        getParent().textFont(getMFont());
        getParent().fill(255);
        
        float y = getCreditsY();
        for (String line : getCredits()) {
            getParent().text(line, getParent().width/2, y);
            y += 40;
        }
        
        setCreditsY(getCreditsY() - 1.0f);
        
        // Allow exit
        getParent().fill(200, 50, 50);
        getParent().text("Click to Return", getParent().width/2, getParent().height - 50);
    }

    private void gameExit(){
        getParent().exit();
    }

    private boolean isMouseOverBtn(float y, float size) {
        float x = getParent().width / 2;
        float w = 300;
        float h = size;
        return isMouseOver(x, y, w, h);
    }


    public AsteroidConstants.GameState handleTitleScreenClick(final AsteroidConstants.GameState currentState){
        if (currentState == AsteroidConstants.GameState.MENU_MAIN) {
            if (isMouseOverBtn(getParent().height/2.03f, getParent().width/20)) {
                return AsteroidConstants.GameState.MENU_GAME_SELECT;
            }
            if(isMouseOverBtn(getParent().height/1.74f, getParent().width/20)){
                return AsteroidConstants.GameState.MENU_HIGH_SCORE;
            }
            if(isMouseOverBtn(getParent().height/1.52f, getParent().width/20)){
                setCreditsY(getParent().height);
                return AsteroidConstants.GameState.MENU_CREDITS;
            }
            if (isMouseOverBtn(getParent().height/1.35f, getParent().width/20)) {
                gameExit();
            }
        } else if (currentState == AsteroidConstants.GameState.MENU_GAME_SELECT) {
            if (isMouseOverBtn(getParent().height/2.03f, getParent().width/20)) {
                AsteroidConstants.GAME_MODE = AsteroidConstants.GameModeEnum.CLASSIC;
                return AsteroidConstants.GameState.PLAYING;
            }
            if (isMouseOverBtn(getParent().height/1.74f, getParent().width/20)) {
                AsteroidConstants.GAME_MODE = AsteroidConstants.GameModeEnum.ENDLESS;
                return AsteroidConstants.GameState.PLAYING;
            }
            if (isMouseOverBtn(getParent().height/1.52f, getParent().width/20)) {
                AsteroidConstants.GAME_MODE = AsteroidConstants.GameModeEnum.TIME_PLAY;
                return AsteroidConstants.GameState.PLAYING;
            }
            if (isMouseOverBtn(getParent().height/1.35f, getParent().width/20)) {
                return AsteroidConstants.GameState.MENU_MAIN;
            }
            if (isMouseOverBtn(getParent().height/1.22f, getParent().width/20)) {
                gameExit();
            }
        } else if(currentState == AsteroidConstants.GameState.MENU_HIGH_SCORE || currentState == AsteroidConstants.GameState.MENU_CREDITS){
            // Click anywhere to return to main menu
            return AsteroidConstants.GameState.MENU_MAIN;
        }
        //Default Fallback
        return currentState;
    }








    // Accessors and APIs ----->
    public void setParent(final PApplet parent){
        this.parent = parent;
    }
    public void setTFont(final PFont tFont){
        this.tFont = tFont;
    }
    public void setMFont(final PFont mFont){
        this.mFont = mFont;
    }
    public void setCredits(final String[] credits){
        this.credits = credits;
    }
    public void setCreditsY(final float creditsY){
        this.creditsY = creditsY;
    }

    public PApplet getParent(){
        return parent;
    }
    public PFont getTFont(){
        return tFont;
    }
    public PFont getMFont(){
        return mFont;
    }
    public String[] getCredits(){
        return credits;
    }
    public float getCreditsY(){
        return creditsY;
    }

}