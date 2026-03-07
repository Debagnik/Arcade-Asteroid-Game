/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2026 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Env_Manager.pde
 */

import java.util.Properties;
import java.io.InputStream;

public static class Env {
    private static final Properties props = new Properties();
    private static boolean isLoaded = false;

    public static void init(PApplet p) {
        if (isLoaded) return;
        
        try {
            InputStream is = p.createInput("project.properties");
            if (is != null) {
                props.load(is);
                is.close();
                isLoaded = true;
                if (AsteroidConstants.enableLogs) System.out.println("Env: Loaded project.properties successfully.");
            } else {
                System.err.println("Env: project.properties file not found in the data/ folder!");
            }
        } catch (Exception e) {
            System.err.println("Env: Failed to load project.properties - " + e.getMessage());
        }
    }

    public static String get(String key) {
        return props.getProperty(key);
    }

    public static String get(String key, String defaultValue) {
        return props.getProperty(key, defaultValue);
    }
}