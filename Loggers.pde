/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2025 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Loggers.pde
 */

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;
import java.util.Objects;
import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

import static org.apache.commons.lang3.StringUtils;

public static class Logger {

    private static final String NULL_ATTR_NAME = "Attribute name null";
    private static final String NULL_VALUE = "null";
    
    private static String logDirectoryPath; 
    
    private static Long sessionEpoch = null;

    public static void setLogDir(String path) {
        logDirectoryPath = StringUtils.isNotEmpty(path) ? path : "./Logs";
    }

    public static void log(Object obj, Integer playerLevel){
        if(AsteroidConstants.GAME_MODE != AsteroidConstants.GameModeEnum.DEBUG){
            return;
        }
        
        StackTraceElement caller = Thread.currentThread().getStackTrace()[2];
        String callSite = caller.getFileName() + ":" + caller.getLineNumber();
        String methodName = caller.getMethodName();
        JSONObject root = new JSONObject();

        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss.SSS");
        root.setString("timestamp", timeFormat.format(new Date()));
        root.setString("gameMode", AsteroidConstants.GAME_MODE.toString());
        root.setString("source", callSite + " -> " + methodName + "()");
        root.setInt("playerLevel", playerLevel);
        
        if (Objects.isNull(obj)) {
           root.setString("objectType", NULL_VALUE);
           root.setJSONObject("data", new JSONObject());
        } else {
           root.setString("objectType", obj.getClass().getSimpleName());
           root.setJSONObject("data", serializeObject(obj));
        }

        String logOutput = "================= DEBUG LOG =================\n" +
                           root.format(2) + 
                           "\n=============================================\n";

        saveLogToFile(logOutput);
    }

    private static void saveLogToFile(String content) {
        try {
            // [CHANGE 2] Initialize the session ID only once per game run
            if (sessionEpoch == null) {
                sessionEpoch = System.currentTimeMillis();
            }

            SimpleDateFormat dateFormat = new SimpleDateFormat("ddMMyyyy");
            String dateStr = dateFormat.format(new Date());
            
            String basePath = (StringUtils.isEmpty(logDirectoryPath)) ? "Logs" : logDirectoryPath;
            
            // Construct: {SketchPath}/Logs/Log_ddMMyyyy/
            File baseDir = new File(basePath);
            File dailyDir = new File(baseDir, "Log_" + dateStr);

            if (!dailyDir.exists()) {
                dailyDir.mkdirs();
            }

            // [CHANGE 3] Use the static sessionEpoch for the filename
            String fileName = "Log_" + sessionEpoch + ".log";
            File logFile = new File(dailyDir, fileName);

            // FileWriter(file, true) appends to the SAME file now
            try(FileWriter fw = new FileWriter(logFile, true); 
            PrintWriter pw = new PrintWriter(fw);){
                pw.write(content);
            } catch (IOException e){
                System.err.println("Logger file writer failed");
                System.err.println(e.getMessage());
                e.printStackTrace();
            }

        } catch (Exception e) {
            System.err.println("Logger Failed: " + e.getMessage());
            e.printStackTrace(); 
        }
    }

    private static JSONObject serializeObject(Object obj){
        JSONObject json = new JSONObject();
        if(Objects.isNull(obj)){
            return json;
        }
        
        if (obj instanceof Collection || obj instanceof Map || obj.getClass().isArray()) {
            return getCmplxValueHelper("content", obj);
        }

        for(Field attr : obj.getClass().getDeclaredFields()){
            if (Modifier.isStatic(attr.getModifiers())) continue;

            attr.setAccessible(true);
            try {
                final String attrName = Objects.nonNull(attr.getName()) ? attr.getName() : NULL_ATTR_NAME;
                final Object attrValue = attr.get(obj);

                JSONObject formattedData = getCmplxValueHelper(attrName, attrValue);

                if(Objects.nonNull(attrValue)){
                    if (formattedData.hasKey(attrName)) {
                        Object innerVal = formattedData.get(attrName);
                        if (innerVal instanceof JSONObject) json.setJSONObject(attrName, (JSONObject)innerVal);
                        else if (innerVal instanceof JSONArray) json.setJSONArray(attrName, (JSONArray)innerVal);
                        else if (innerVal instanceof String) json.setString(attrName, (String)innerVal);
                        else if (innerVal instanceof Boolean) json.setBoolean(attrName, (Boolean)innerVal);
                        else if (innerVal instanceof Integer) json.setInt(attrName, (Integer)innerVal);
                        else if (innerVal instanceof Float) json.setFloat(attrName, (Float)innerVal);
                    }
                    
                    java.util.Set<String> keys = formattedData.keys();
                    for(String key : keys) {
                        if(!key.equals(attrName)) {
                            // Attempting multiple typed setters; exceptions expected for type mismatches
                             try { json.setJSONObject(key, formattedData.getJSONObject(key)); } catch(Exception e) {}
                             try { json.setJSONArray(key, formattedData.getJSONArray(key)); } catch(Exception e) {}
                             try { json.setString(key, formattedData.getString(key)); } catch(Exception e) {}
                             try { json.setInt(key, formattedData.getInt(key)); } catch(Exception e) {}
                             try { json.setBoolean(key, formattedData.getBoolean(key)); } catch(Exception e) {}
                        }
                    }
                } else{
                    json.setString(attrName, NULL_VALUE);
                }

            } catch (IllegalAccessException e){
                json.setString(attr.getName(), "[ACCESS DENIED]");
            }
        }
        return json;
    }

    private static JSONObject getCmplxValueHelper(final String name, final Object attrValue){
        JSONObject json = new JSONObject();
        if(Objects.isNull(attrValue)){
            json.setString(name, NULL_VALUE);
            return json;
        }
        if(attrValue instanceof PVector){
            final PVector vect = (PVector) attrValue;
            final JSONObject vectJson = new JSONObject();
            vectJson.setFloat("x", vect.x);
            vectJson.setFloat("y", vect.y);
            vectJson.setFloat("z", vect.z);
            json.setJSONObject(name, vectJson);

        } else if(attrValue.getClass().isArray()){ 
            final JSONArray jsonArray = new JSONArray();
            final int arrayLoggingLimit = AsteroidConstants.COLLECTION_LOGGING_LIMIT;
            final int arrayLength = Array.getLength(attrValue);
            final boolean isTruncated = (arrayLength > arrayLoggingLimit);
            json.setBoolean("isArrayTruncated", isTruncated);
            json.setInt("arrayLength", arrayLength);
            
            if(isTruncated) json.setInt("arrayLoggingLimit", arrayLoggingLimit);

            for(int i=0; i < (isTruncated ? arrayLoggingLimit : arrayLength); i++){
                Object item = Array.get(attrValue, i);
                jsonArray.append(item != null ? item.toString() : NULL_VALUE);
            }
            if(isTruncated) jsonArray.append(" ====== [TRUNCATED] ====== ");

            json.setJSONArray(name, jsonArray);

        } else if(attrValue instanceof Collection){ 
            Collection<?> col = (Collection<?>) attrValue;
            ArrayList<Object> colArray = new ArrayList<Object>(col);
            final JSONArray jsonArray = new JSONArray();
            final int collectionLoggingLimit = AsteroidConstants.COLLECTION_LOGGING_LIMIT;
            final int collectionLength = col.size();
            final boolean isTruncated = (collectionLength > collectionLoggingLimit);

            json.setString("type", attrValue.getClass().getSimpleName());
            json.setBoolean("isCollectionTruncated", isTruncated);
            json.setInt("size", collectionLength);
            if(isTruncated) json.setInt("collectionLoggingLimit", collectionLoggingLimit);

            for(int i = 0; i < (isTruncated ? collectionLoggingLimit : collectionLength); i++){
                Object item = colArray.get(i);
                jsonArray.append(item != null ? item.toString() : NULL_VALUE);
            }
            if(isTruncated) jsonArray.append(" ====== [TRUNCATED] ====== ");

            json.setJSONArray(name, jsonArray);
        
        } else if(attrValue instanceof Map){ 
            Map<?, ?> attrMap = (Map<?, ?>) attrValue;
            final JSONArray jsonMap = new JSONArray();
            final int mapLoggingLimit = AsteroidConstants.COLLECTION_LOGGING_LIMIT;
            final int mapSize = attrMap.size();
            final boolean isTruncated = mapSize > mapLoggingLimit;

            json.setBoolean("isMapTruncated", isTruncated);
            json.setInt("mapSize", mapSize);

            if(isTruncated) json.setInt("mapLoggingLimit", mapLoggingLimit);

            int i = 0;
            for(Map.Entry<?, ?> entry : attrMap.entrySet()){
                if(i >= mapLoggingLimit) break;
                JSONObject kv = new JSONObject();
                kv.setString("key", String.valueOf(entry.getKey()));
                kv.setString("keyType", Objects.nonNull(entry.getKey()) ? entry.getKey().getClass().getSimpleName() : NULL_VALUE);
                kv.setString("value", String.valueOf(entry.getValue()));
                kv.setString("valueType", Objects.nonNull(entry.getValue()) ? entry.getValue().getClass().getSimpleName() : NULL_VALUE);
                jsonMap.append(kv);
                i++;
            }
            if (isTruncated) jsonMap.append(" ====== [TRUNCATED] ====== ");

            json.setJSONArray(name, jsonMap);

        } else if(attrValue instanceof String || attrValue instanceof Character || attrValue instanceof Number || attrValue instanceof Boolean || attrValue.getClass().isEnum()){ 
            json.setString(name, attrValue.toString());
        } else { 
            final JSONObject fallback = new JSONObject();
            fallback.setString("error", "DATATYPE NOT DEFINED IN LOGGER: " + attrValue.getClass().getSimpleName());
            json.setJSONObject(name, fallback);
        }

        return json;
    }
}
