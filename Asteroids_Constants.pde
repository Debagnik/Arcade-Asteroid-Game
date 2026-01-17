/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Asteroids_Constants.pde
 */


public static class AsteroidConstants {
    // global Constants
    public static final float PLAYER_MAX_HP = 100.0;
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
    public static final int RESPAWN_TIMER = 90;
    public static final int INVINCIBLE_TIMER = 150;

    // Asteroids constants
    public static final int INITIAL_ASTEROID_COUNT = 5; //This is a non-zero value
    public static final float ASTEROID_MAX_SPEED = 5.0;
    public static final float MIN_ASTEROID_SIZE = 10.0;
    public static final float MAX_ASTEROID_SIZE = 50.0;
    public static final float ASTEROID_SHIP_SAFE_DISTANCE = 200;
    public static enum AsteroidExplosionTypeEnum {
        BIG_EXPLOSION,
        MEDIUM_EXPLOSION,
        SMALL_EXPLOSION
    };

    // LASER CONSTANTS
    public static final float LASER_SPEED = SHIP_MAX_SPEED + 2.0;
    public static final int LASER_LIFESPAN = 60; // Frames before it disappears
    public static final float LASER_SIZE = 0.5;

    // Debris Constants
    public static final float EXPLOSION_FORCE_MULTIPLIER = 0.5; 
    public static final int PARTICLE_COUNT_SMALL = 12; 
    public static final int PARTICLE_COUNT_MEDIUM = 8;
    public static final int PARTICLE_COUNT_BIG = 5;

    // Alien UFO Constants
    public static final boolean ALLOW_MULTIPLE_UFOS = true;
    public static final int MAX_UFO_COUNT = 2;
    public static final int UFO_START_LEVEL = 5; // The player level that BIG UFOs will start Spawning
    public static final int UFO_DUAL_SPAWN_LEVEL = 10;  // The player Level that Both Small and Big UFOs will start spawning
    public static enum UFOTypeEnum {
        BIG,
        SMALL
    }

    // Alien UFO Settings
    public static final float UFO_SIZE_BIG = 40.0;
    public static final float UFO_SIZE_SMALL = 20.0;
    public static final float UFO_SPEED_BIG = 2.0;
    public static final float UFO_SPEED_SMALL = 4.0;
    public static final float UFO_FIRE_RATE = 60;
    public static final float UFO_SPAWN_CHANCE = 0.005;

    // UFO Damage: Small UFO deals MORE damage (harder to hit, hits harder)
    public static final float DAMAGE_BIG_UFO = 10.0;
    public static final float DAMAGE_SMALL_UFO = 20.0;

    // UFO Asteroid Avoidance System Constant
    public static final float UFO_AVOIDANCE_RADIUS = 150.0;

    // Logger Constants
    public static enum GameModeEnum{
        TEST,
        DEBUG,
        LOG,
        PROD
    };
    public static GameModeEnum GAME_MODE = GameModeEnum.PROD;
    public static int COLLECTION_LOGGING_LIMIT = 25;
    public static final String LOGGING_DIR = "./Logs";

}