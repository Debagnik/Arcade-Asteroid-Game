/*
 * Asteroids Game
 * License DWTFYWTPL <https://www.wtfpl.net/about/>
 * Copyright 2026 Rak Kingabed <debagnik@debagnik.in>
 * FILE: Network_Manager.pde
 */

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import java.util.concurrent.TimeUnit;
import java.io.IOException;

public static class NetworkManager {

    // Define JSON media type for our payload bodies
    public static final MediaType JSON = MediaType.get("application/json; charset=utf-8");

    // Singleton OkHttpClient with connection pooling and sensible timeouts (15 seconds)
    private static final OkHttpClient client = new OkHttpClient.Builder()
            .connectTimeout(15, TimeUnit.SECONDS)
            .writeTimeout(15, TimeUnit.SECONDS)
            .readTimeout(15, TimeUnit.SECONDS)
            .build();

    public static String post(String url, String jsonBody, String token) throws IOException {
        // Ensure we don't pass a null body for a POST request
        String safeBody = (jsonBody != null && !jsonBody.isEmpty()) ? jsonBody : "{}";
        RequestBody body = RequestBody.create(safeBody, JSON);

        Request.Builder requestBuilder = new Request.Builder()
                .url(url)
                .post(body);

        // Inject the Authorization header if a token is provided
        if (token != null && !token.isEmpty()) {
            requestBuilder.addHeader("Authorization", "Bearer " + token);
        }

        // Execute the request
        try (Response response = client.newCall(requestBuilder.build()).execute()) {
            if (!response.isSuccessful()) {
                throw new IOException("Unexpected HTTP code: " + response.code() + " - " + response.message());
            }
            return response.body().string();
        }
    }

    public static String get(String url, String token) throws IOException {
        Request.Builder requestBuilder = new Request.Builder()
                .url(url)
                .get();

        // Inject the Authorization header if a token is provided
        if (token != null && !token.isEmpty()) {
            requestBuilder.addHeader("Authorization", "Bearer " + token);
        }

        // Execute the request
        try (Response response = client.newCall(requestBuilder.build()).execute()) {
            if (!response.isSuccessful()) {
                throw new IOException("Unexpected HTTP code: " + response.code() + " - " + response.message());
            }
            return response.body().string();
        }
    }
}