/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Asteroids_Constants.pde
 */


public static class AsteroidConstants {
    // global Constants
    public static final float TWO_PI = 6.28318530718;
    public static final float PI = 3.14159265359;
    // Enum for trigonometric functions
    public static enum TrigonometricFunctionEnum {
        SINE,
        COSINE,
        TANGENT
    };

    // ship constants
    public static final float SHIP_SIZE = 15.0;
    public static final float SHIP_ROTATE_SPEED = 0.05;
    public static final float SHIP_THRUST_POWER = 0.1;
    public static final float SHIP_MAX_SPEED = 6.0;
    public static final float SHIP_FRICTION = 0.99;

    // Asteroids constants
    public static final int INITIAL_ASTEROID_COUNT = 5;
    public static final float ASTEROID_MAX_SPEED = SHIP_MAX_SPEED + 2.0;
    public static final float MIN_ASTEROID_SIZE = 10.0;
    public static final float MAX_ASTEROID_SIZE = 50.0;
    public static final float ASTEROID_SHIP_SAFE_DISTANCE = 200;

    // LASER CONSTANTS
    public static final float LASER_SPEED = SHIP_MAX_SPEED + 2.0;
    public static final int LASER_LIFESPAN = 70; // Frames before it disappears
    public static final float LASER_SIZE = 0.5;

    // Logger Constants - Will be used later
    public static enum GameModeEnum{
        TEST,
        DEBUG,
        PROD
    };
    public static GameModeEnum GAME_MODE = GameModeEnum.DEBUG;
    public static int COLLECTION_LOGGING_LIMIT = 25;



}