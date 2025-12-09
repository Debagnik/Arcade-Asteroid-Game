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
    public static final float SHIP_SIZE = 10.0;
    public static final float SHIP_ROTATE_SPEED = 0.05;
    public static final float SHIP_THRUST_POWER = 0.1;
    public static final float SHIP_MAX_SPEED = 6.0;
    public static final float SHIP_FRICTION = 0.99;

    // Asteroids constants
    public static final int INITIAL_ASTEROID_COUNT = 10;
    public static final float ASTEROID_MAX_SPEED = SHIP_MAX_SPEED + 2.0;

}