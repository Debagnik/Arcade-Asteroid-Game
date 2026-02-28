/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2026 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Save_Game_Manager.pde
 */

import processing.data.JSONObject;
import processing.data.JSONArray;
import java.io.File;
import java.util.UUID;
import java.util.Base64;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;

public static class SaveGameManager {
    private static final String SAVE_FILE_NAME = "game.data";
    private static final int MAX_SESSIONS_HISTORY = 100;
    private static final String SEED_SEPARATOR = "@@@";
    private static final String SALT = "privacy-apron-privacy-eternal-dominoes-approach";
    private static final String XOR_KEY = "B4Y&%!*wZ5b!WRgVo#9EUB78";
    private static final String CHECKSUM_SEPARATOR = "(>w<)";

    public static void saveGameSession(PApplet p, String mode, int score, int timePlayed, String username) {
        
        final String dirPath = getOSSpecificSaveDirectory();
        File saveDirObj = new File(dirPath);
        //Logger.log(dirPath, "OS Specific save path");

        if (!saveDirObj.exists()) {
            saveDirObj.mkdirs(); 
        }
        
        final String fullPath = dirPath + File.separator + SAVE_FILE_NAME;
        File saveFileObj = new File(fullPath);

        File parentDir = saveFileObj.getParentFile();
        if (parentDir != null && !parentDir.exists()) {
            parentDir.mkdirs();
        }

        JSONObject root;


        if(saveFileObj.exists()){
            try{
                String[] fileLines = p.loadStrings(fullPath);
                String rawData = String.join("\n", fileLines);
                
                //Decoding the data before use
                final String decodedData = verifySignAndDecode(rawData);

                root = p.parseJSONObject(decodedData);
                if(Objects.isNull(root)){
                    throw new RuntimeException("Parsed JSON is null.");
                }
            } catch(Exception ex){
                System.err.println("Warning: Corrupted or tampered save file. Creating a new one." + ex.getMessage());
                root = createInitialSaveStructure();
            }
        } else {
            root = createInitialSaveStructure();
        }

        //Update Metadata very rudimentary
        JSONObject metadata = root.getJSONObject("metadata");
        if(Objects.isNull(metadata)){
            metadata = new JSONObject();
            metadata.setLong("totalTimePlayed", 0);
            root.setJSONObject("metadata", metadata);
        }
        metadata.setLong("totalTimePlayed", metadata.getLong("totalTimePlayed") + timePlayed);

        //create current session
        JSONObject currentSession = new JSONObject();
        currentSession.setLong("score", score);
        currentSession.setString("mode", mode);
        currentSession.setString("playerUsername", username);
        currentSession.setLong("timePlayed", timePlayed);
        final long timestamp = System.currentTimeMillis();
        final StringBuilder sessionSeed = new StringBuilder();
        sessionSeed.append(username).append(SEED_SEPARATOR).append(mode).append(SEED_SEPARATOR).append(score).append(SEED_SEPARATOR).append(timePlayed).append(SEED_SEPARATOR).append(timestamp);
        final UUID sessionUUID = UUID.nameUUIDFromBytes(sessionSeed.toString().getBytes(StandardCharsets.UTF_8));
        currentSession.setString("sessionId", sessionUUID.toString());

        //Update high score
        JSONObject currentHighScores = root.getJSONObject("highScores");
        if(Objects.isNull(currentHighScores)){
            currentHighScores = new JSONObject();
            currentHighScores.setJSONObject("CLASSIC", generateEmptyScore());
            currentHighScores.setJSONObject("ENDLESS", generateEmptyScore());
            currentHighScores.setJSONObject("TIME_BOUND", generateEmptyScore());
            root.setJSONObject("highScores", currentHighScores);
        }
        root.setJSONObject("highScores", updateHighScore(currentHighScores, score, mode, sessionUUID.toString(), username, timestamp));

        //Update the session history
        JSONArray sessionHistory = root.getJSONArray("sessionHistory");
        if(Objects.isNull(sessionHistory)){
            sessionHistory = new JSONArray();
        }

        JSONArray updatedSessions = new JSONArray();
        updatedSessions.setJSONObject(0, currentSession);

        int priorHistoryIndex = 1;
        for(int i = 0; i < sessionHistory.size() && priorHistoryIndex < MAX_SESSIONS_HISTORY; i++){
            updatedSessions.setJSONObject(priorHistoryIndex, sessionHistory.getJSONObject(i));
            priorHistoryIndex++;
        }

        root.setJSONArray("sessionHistory", updatedSessions);

        String finalJsonString;
        if(AsteroidConstants.enableLogs){
            finalJsonString = root.format(2); //Prettfied Json String
        } else {
            finalJsonString = root.format(-1); //Minified raw Json String.
        }
        //Logger.log(finalJsonString, "This is the final Json String");

        final String encodedAndSignedPayload = encodeAndSign(finalJsonString);

        p.saveStrings(fullPath, new String[] { encodedAndSignedPayload });

        if(AsteroidConstants.enableLogs){
            System.out.println("Game saved successfully to: " + fullPath);
        }


    }

    private static JSONObject updateHighScore(final JSONObject currentHighScores, final long score, final String mode, final String sessionId, final String playerUsername, final long timeStamp){
        JSONObject modeHighScore = currentHighScores.getJSONObject(mode);

        JSONObject newModeHighScore = new JSONObject();
        newModeHighScore.setLong("score", score);
        newModeHighScore.setString("scoredBy", playerUsername);
        newModeHighScore.setString("sessionId", sessionId);
        newModeHighScore.setLong("timestamp", timeStamp);
        final StringBuilder hsSeed = new StringBuilder();
        hsSeed.append(playerUsername).append(SEED_SEPARATOR).append(score).append(SEED_SEPARATOR).append(sessionId).append(SEED_SEPARATOR).append(timeStamp);
        final UUID hsId = UUID.nameUUIDFromBytes(hsSeed.toString().getBytes(StandardCharsets.UTF_8));
        newModeHighScore.setString("highScoreId", hsId.toString());

        if(Objects.nonNull(modeHighScore) && modeHighScore.getLong("score", Long.MIN_VALUE) < score){
            currentHighScores.setJSONObject(mode, newModeHighScore);
        } else if(Objects.isNull(modeHighScore)){
            currentHighScores.setJSONObject(mode, newModeHighScore);
        }
        
        return currentHighScores;
    }

    private static JSONObject createInitialSaveStructure() {
        JSONObject root = new JSONObject();

        //Create new metadata.
        JSONObject metadata = new JSONObject();
        metadata.setString("playerOS", System.getProperty("os.name"));
        metadata.setLong("totalTimePlayed", 0);
        metadata.setLong("timestamp", System.currentTimeMillis());
        metadata.setString("systemUUID", UUID.randomUUID().toString());
        root.setJSONObject("metadata", metadata);

        //Create new HighScore
        JSONObject highScores = new JSONObject();
        highScores.setJSONObject("CLASSIC", generateEmptyScore());
        highScores.setJSONObject("ENDLESS", generateEmptyScore());
        highScores.setJSONObject("TIME_BOUND", generateEmptyScore());
        root.setJSONObject("highScores", highScores);

        //Create new history
        root.setJSONArray("sessionHistory", new JSONArray());
        return root;
    }

    public static JSONObject generateEmptyScore(){
        JSONObject empty = new JSONObject();
        empty.setLong("score", Long.MIN_VALUE); // Impossible value
        empty.setString("scoredBy", "Jane Doe"); //Made up name yes I am intentionally hardcoding this.
        empty.setString("sessionId", "1234-5678-9012-3456");
        empty.setLong("timestamp", 0);
        empty.setString("highScoreId", "0987-6543-2109-8765");
        return empty;
    }

    private static String encodeAndSign(final String rawString){
        //encode once
        final String base64Encoded = Base64.getEncoder().encodeToString(rawString.getBytes(StandardCharsets.UTF_8));
        //Logger.log(base64Encoded);
        //add Salt
        final StringBuilder saltedBase64Encoded = new StringBuilder();
        saltedBase64Encoded.append(base64Encoded).append(SALT);
        //Logger.log(saltedBase64Encoded.toString());

        //TODO: Add pepper

        //Apply XOR-Mask
        final String protectedData = maskInXOR(saltedBase64Encoded.toString(), XOR_KEY);
        //Logger.log(protectedData);
        //generate checksum
        final String checksum = generateChecksum(protectedData);
        //Logger.log(checksum);

        final StringBuilder signedProtectedData = new StringBuilder();

        signedProtectedData.append(protectedData).append(CHECKSUM_SEPARATOR).append(checksum);
        //Logger.log(signedProtectedData.toString());

        return signedProtectedData.toString();

    }

    private static String maskInXOR(final String rawData, final String key){
        final byte[] inputBytes = rawData.getBytes(StandardCharsets.UTF_8);
        final byte[] keyBytes = key.getBytes(StandardCharsets.UTF_8);
        byte[] maskedBytes = new byte[inputBytes.length];

        for (int i = 0; i < inputBytes.length; i++) {
            maskedBytes[i] = (byte) (inputBytes[i] ^ keyBytes[i % keyBytes.length]);
        }
        //Logger.log(maskedBytes);
        //Logger.log(maskedBytes.length);

        //Second encoding to Base64
        final String secondEncoding = Base64.getEncoder().encodeToString(maskedBytes);
        //Logger.log(secondEncoding);

        return secondEncoding;

    }

    private static String generateChecksum(final String rawData){
        try{
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(rawData.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            //Logger.log(hexString.toString());
            return hexString.toString();
        } catch (Exception ex) {
            throw new RuntimeException("SHA-256 not supported on this system.", ex);
        }
    }

    @SuppressWarnings("deprecation")
    private static String verifySignAndDecode(final String encodedData){
        //Split Checksum and data
        String[] rawData = StringUtils.splitByWholeSeparator(encodedData, CHECKSUM_SEPARATOR);
        if(Objects.isNull(rawData) || rawData.length != 2){
            throw new RuntimeException("Save file format invalid. Missing checksum.");
        }

        final String protectedData = rawData[0];
        final String providedChecksum = rawData[1];

        //Verify CheckSum
        final String expectedChecksum = generateChecksum(protectedData);
        //Logger.log(providedChecksum, "Provided Checksum");
        //Logger.log(expectedChecksum, "Expected Checksum");
        if(StringUtils.isBlank(providedChecksum) || !StringUtils.equals(expectedChecksum, providedChecksum)){
            throw new RuntimeException("CheckSum mismatch");
        }

        //Undo XOR Masking
        final String saltedBase64Encoded = demaskXOR(protectedData, XOR_KEY);

        if(!StringUtils.endsWith(saltedBase64Encoded, SALT)){
            throw new RuntimeException("Salt not found, Data tampered or corrupted");
        }

        //Desalting
        final String b64encoded = saltedBase64Encoded.substring(0, saltedBase64Encoded.length() - SALT.length());

        //Final Decoding
        final byte[] decodedData = Base64.getDecoder().decode(b64encoded);
        final String decodedJsonString = new String(decodedData, StandardCharsets.UTF_8);

        return decodedJsonString;

    }

    private static String demaskXOR(final String encodedData, final String key){
        // Decode second layer of base64
        final byte[] inputBytes = Base64.getDecoder().decode(encodedData);
        final byte[] keyBytes = key.getBytes(StandardCharsets.UTF_8);
        byte[] outputBytes = new byte[inputBytes.length];
        //XOR masking again to demask
        for (int i = 0; i < inputBytes.length; i++) {
            outputBytes[i] = (byte) (inputBytes[i] ^ keyBytes[i % keyBytes.length]);
        }

        return new String(outputBytes, StandardCharsets.UTF_8);

    }

    private static String getOSSpecificSaveDirectory() {
        String os = System.getProperty("os.name").toLowerCase();
        String userHome = System.getProperty("user.home");
        String appFolderName = "ArcadeAsteroids"; // Folder name for your game

        if (os.contains("win")) {
            String appData = System.getenv("APPDATA");
            if (appData != null) {
                return appData + File.separator + appFolderName;
            }
            return userHome + File.separator + "AppData" + File.separator + "Roaming" + File.separator + appFolderName;
            
        } else if (os.contains("mac")) {
            return userHome + File.separator + "Library" + File.separator + "Application Support" + File.separator + appFolderName;
            
        } else {
            String xdgDataHome = System.getenv("XDG_DATA_HOME");
            if (xdgDataHome != null) {
                return xdgDataHome + File.separator + appFolderName;
            }
            return userHome + File.separator + ".local" + File.separator + "share" + File.separator + appFolderName;
        }
    }




}