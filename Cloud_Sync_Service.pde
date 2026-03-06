/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2026 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Cloud_Sync_Service.pde
 */

import processing.data.JSONObject;
import java.io.File;
import java.security.*;
import java.security.spec.MGF1ParameterSpec;
import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import javax.crypto.spec.OAEPParameterSpec;
import javax.crypto.spec.PSource;
import java.util.Base64;
import java.nio.charset.StandardCharsets;
import org.apache.commons.lang3.StringUtils;

public static class CloudSyncService {

    private static final String BASE_URL = Env.get("game.server.base.uri");
    private static String sessionJwtToken = null;

    //Crypto configs
    private static final String RSA_ALGO = "RSA";
    private static final String RSA_TRANSFORM = "RSA/ECB/OAEPWithSHA-1AndMGF1Padding";
    private static final String AES_TRANSFORM = "AES/CBC/PKCS5Padding";
    
    // Called when the game loads the Title Screen
    public static String getPepperStringFromVersion(String pepperVersion) {
        try{
            ensureAuthenticated();
            String url = BASE_URL + "/api/system/pepper?version=" + pepperVersion;
            String responseStr = NetworkManager.get(url, sessionJwtToken);
            JSONObject responseJson = processing.data.JSONObject.parse(responseStr);
            return responseJson.getString("pepper");
        } catch (Exception ex){
            System.err.println("CloudSyncService: Failed to fetch pepper version: " + pepperVersion + "\n" + ex.getMessage());
            return null;
        }
        
    }
    
    // Called silently in the background when Player Dies
    public static void triggerSync(PApplet p) {
        new Thread(() -> {
            try {
                if (AsteroidConstants.enableLogs) {
                    System.out.println("CloudSyncService: Starting Background Sync...");
                }
                final String fullPath = SaveGameManager.getOSSpecificSaveDirectory() + File.separator + AsteroidConstants.GAME_SAVE_FILE_NAME;
                final File saveFile = new File(fullPath);
                if(!saveFile.exists()){
                    System.err.println("CloudSyncService: game.data not found. Aborting sync.");
                    return;
                }
                String[] fileContent = p.loadStrings(fullPath);
                JSONObject diskWrapper = p.parseJSONObject(String.join("\n", fileContent));

                boolean isPeppered = diskWrapper.getBoolean("isPeppered", false);
                String pepperVersion = isPeppered && StringUtils.isNotBlank(diskWrapper.getString("pepperVersion")) ? diskWrapper.getString("pepperVersion") : null;

                ensureAuthenticated();
                if(!isPeppered){
                    String newVersion = "v" + (int)(Math.random() * 10);
                    String fetchedPepper = getPepperStringFromVersion(newVersion);
                    if(StringUtils.isNotBlank(fetchedPepper)){
                        SaveGameManager.addPepperToSaveFile(p, fetchedPepper, newVersion);

                        // Re-read the newly upgraded file from disk
                        fileContent = p.loadStrings(fullPath);
                        diskWrapper = p.parseJSONObject(String.join("\n", fileContent));

                        isPeppered = true;
                        pepperVersion = newVersion;

                        System.out.println("CloudSyncService: Successfully upgraded save to " + newVersion);
                    } else {
                        System.err.println("CloudSyncService: Upgrade failed. Syncing unpeppered fallback.");
                    }
                }
                //Prepare sync payload
                final String payloadGameScore = diskWrapper.getString("gameScore");
                boolean isEncrypted = false;
                String finalPayloadScore = payloadGameScore;

                //Getting the RSA-AES Key-exchange
                try{
                    //generate RSA Key-pair
                    KeyPairGenerator kpg = KeyPairGenerator.getInstance(RSA_ALGO);
                    kpg.initialize(2048);
                    KeyPair kp = kpg.generateKeyPair();

                    //Format public key as PEM
                    String pubKeyBase64 = Base64.getMimeEncoder(64, new byte[]{'\n'}).encodeToString(kp.getPublic().getEncoded());
                    String pemPublicKey = "-----BEGIN PUBLIC KEY-----\n" + pubKeyBase64 + "\n-----END PUBLIC KEY-----";

                    JSONObject keyReq = new JSONObject();
                    keyReq.setString("publicKey", pemPublicKey);

                    byte[] aesKey = null;
                    int decryptAttempt = 0;
                    final int maxRetry = AsteroidConstants.INTREGRATION_MAX_RETRIES;

                    while(decryptAttempt < maxRetry && aesKey == null){
                        try {
                            String getKeyApiEndpointUri = BASE_URL + "/api/getEncryptionKey";
                            String keyRes = NetworkManager.post(getKeyApiEndpointUri, keyReq.toString(), sessionJwtToken);
                            JSONObject aesKeyObj = processing.data.JSONObject.parse(keyRes);
                            String encryptedAesBase64 = aesKeyObj.getString("encryptedAesKey");
                            Cipher rsaCipher = Cipher.getInstance(RSA_TRANSFORM);
                            OAEPParameterSpec oaepParams = new OAEPParameterSpec("SHA-1", "MGF1", MGF1ParameterSpec.SHA1, PSource.PSpecified.DEFAULT);
                            rsaCipher.init(Cipher.DECRYPT_MODE, kp.getPrivate(), oaepParams);
                            aesKey = rsaCipher.doFinal(Base64.getDecoder().decode(encryptedAesBase64));
                        } catch (Exception ex){
                            decryptAttempt++;
                            System.err.println("CloudSyncService: AES Decrypt attempt " + decryptAttempt + " failed.");
                        }
                    }

                    //If AES-key is successfully Decrypted the use Server's AES-key, encrypt the payload
                    if(Objects.nonNull(aesKey)){
                        try{
                            byte[] iv = new byte[16];
                            new SecureRandom().nextBytes(iv);
                            IvParameterSpec ivSpec = new IvParameterSpec(iv);

                            SecretKeySpec skeySpec = new SecretKeySpec(aesKey, "AES");
                            Cipher aesCipher = Cipher.getInstance(AES_TRANSFORM);
                            aesCipher.init(Cipher.ENCRYPT_MODE, skeySpec, ivSpec);

                            byte[] cipherText = aesCipher.doFinal(payloadGameScore.getBytes(StandardCharsets.UTF_8));

                            //Combine IV + CypherText
                            byte[] combined = new byte[iv.length + cipherText.length];
                            System.arraycopy(iv, 0, combined, 0, iv.length);
                            System.arraycopy(cipherText, 0, combined, iv.length, cipherText.length);

                            finalPayloadScore = Base64.getEncoder().encodeToString(combined);

                            isEncrypted = true;
                        } catch (Exception ex){
                            System.err.println("CloudSyncService: AES Encryption failed. Falling back to raw gameScore.");
                        }
                    } else {
                        System.err.println("CloudSyncService: Key Exchange completely failed. Falling back to raw gameScore.");
                    }

                } catch(Exception ex){
                    System.err.println("CloudSyncService: RSA Generation failed. Falling back to raw gameScore.");
                }

                JSONObject syncPayload = new JSONObject();
                syncPayload.setBoolean("isPeppered", isPeppered);
                syncPayload.setBoolean("isEncrypted", isEncrypted);
                syncPayload.setString("gameScore", finalPayloadScore);

                String syncUri = BASE_URL + "/api/scores";
                if(isPeppered && StringUtils.isNotBlank(pepperVersion)){
                    syncUri += "?version=" + pepperVersion;
                }
                Logger.log(syncUri, "The URL Endpoint for Score Sync");
                Logger.log(syncPayload.toString(), "Payload for ScoreSync API");

                boolean syncSuccess = false;
                int maxSyncRetry = AsteroidConstants.INTREGRATION_MAX_RETRIES;
                for(int i = 0; i < maxSyncRetry; i++){
                    try{
                        String syncRes = NetworkManager.post(syncUri, syncPayload.toString(), sessionJwtToken);
                        System.out.println("CloudSyncService: Sync Successful! Server says: " + syncRes);
                        syncSuccess = true;
                        break;
                    }catch (Exception e){
                        System.err.println("CloudSyncService: Sync attempt " + (i+1) + " failed: " + e.getMessage());
                        try { Thread.sleep(2000); } catch (InterruptedException ie) {}
                    }
                }
                if(!syncSuccess){
                    System.err.println("CloudSyncService: Score Sync failed entirely after " + maxSyncRetry + " attempts.");
                }
                    
            }catch (Exception e){
                System.err.println("CloudSyncService: Fatal Error in background sync: " + e.getMessage());
                e.printStackTrace();
            }
        }).start();
    }

    private static void ensureAuthenticated() throws Exception {
        if (AsteroidConstants.enableLogs) System.out.println("CloudSyncService: Fetching new Auth Token...");
        
        String authRes = NetworkManager.post(BASE_URL + "/api/auth", "{}", null);
        JSONObject authObj = processing.data.JSONObject.parse(authRes);
        sessionJwtToken = authObj.getString("token");
    }

    public static JSONObject fetchLeaderboard() {
        try {
            // We must authenticate first since the token is no longer cached
            ensureAuthenticated();
            
            String url = BASE_URL + "/api/leaderboard";
            String responseStr = NetworkManager.get(url, sessionJwtToken);
            
            return processing.data.JSONObject.parse(responseStr);
        } catch (Exception e) {
            System.err.println("CloudSyncService: Failed to fetch leaderboard. " + e.getMessage());
            return null; // Return null on failure so the UI knows to show an error or offline state
        }
    }
}