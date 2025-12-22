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

public static class Logger{

    private static final String NULL_ATTR_NAME = "Attribute name null";
    private static final String NULL_VALUE = "null";

    /**
     * Main Logging Method.
     * Checks GameMode and prints detailed object state.
     */
    public static void log(Object obj, int playerLevel){
        if(AsteroidConstants.GAME_MODE != AsteroidConstants.GameModeEnum.DEBUG){
            return;
        }
        StackTraceElement caller = Thread.currentThread().getStackTrace()[2];
        String callSite = caller.getFileName() + ":" + caller.getLineNumber();
        String methodName = caller.getMethodName();
        JSONObject root = new JSONObject();

        root.setString("timestamp", hour() + ":" + minute() + ":" + second());

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

        System.out.println("================= DEBUG LOG =================");
        System.out.println(root.format(2));
        System.out.println("============================================");

    }

    private static JSONObject serializeObject(Object obj){
        JSONObject json = new JSONObject();
        if(Objects.isNull(obj)){
            return json;
        }
        // Get all the attributes of the Object and loop through it.
        for(Field attr : obj.getClass().getDeclaredFields()){
            attr.setAccessible(true);
            try {
                final String attrName = Objects.nonNull(attr.getName()) ? attr.getName() : NULL_ATTR_NAME;
                final Object attrValue = attr.get(obj);

                JSONObject formattedData = getCmplxValueHelper(attrName, attrValue);

                if(Objects.nonNull(attrValue)){
                    json.setJSONObject(attrName, formattedData);
                } else{
                    json.setString(attrName, NULL_VALUE);
                }

            } catch (IllegalAccessException e){
                json.setString(attr.getName(), "[ACCESS DENIED]");
                println(e.getMessage());
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
        // Handle PVector
        if(attrValue instanceof PVector){
            final PVector vect = (PVector) attrValue;
            final JSONObject vectJson = new JSONObject();
            vectJson.setFloat("x", vect.x);
            vectJson.setFloat("y", vect.y);
            vectJson.setFloat("z", vect.z);
            json.setJSONObject(name, vectJson);

        } else if(attrValue.getClass().isArray()){ //HANDLE ARRAYS (Primitive & Wrapper)
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

        } else if(attrValue instanceof Collection){  //Handle Collections
            Collection<?> col = (Collection<?>) attrValue;
            ArrayList<Object> colArray = new ArrayList<Object>(col);
            final JSONArray jsonArray = new JSONArray();
            final int collectionLoggingLimit = AsteroidConstants.COLLECTION_LOGGING_LIMIT;
            final int collectionLength = col.size();
            final boolean isTruncated = (collectionLength > collectionLoggingLimit);

            json.setString("type", attrValue.getClass().getSimpleName());
            json.setBoolean("isCollectionTruncated", isTruncated);
            json.setInt("size", collectionLength);
            if(isTruncated) json.setInt("CollectionLoggingLimit", collectionLoggingLimit);

            for(int i = 0; i < (isTruncated ? collectionLoggingLimit : collectionLength); i++){
                Object item = colArray.get(i);
                jsonArray.append(item != null ? item.toString() : NULL_VALUE);
            }
            if(isTruncated) jsonArray.append(" ====== [TRUNCATED] ====== ");

            json.setJSONArray(name, jsonArray);
        
        } else if(attrValue instanceof Map<?, ?>){ //Handles Maps
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


        }else if(attrValue instanceof String || attrValue instanceof Character || attrValue instanceof Number || attrValue instanceof Boolean || attrValue.getClass().isEnum()){ // Handle rest of the primitive Data types or Enums
            json.setString(name, attrValue.toString());
        } else { // Handles Unknown Datatypes acting as a fallback
            final JSONObject fallback = new JSONObject();
            fallback.setString("error", "DATATYPE NOT DEFINED IN LOGGER: " + attrValue.getClass().getSimpleName());
            json.setJSONObject(name, fallback);
        }

        return json;

    }

}