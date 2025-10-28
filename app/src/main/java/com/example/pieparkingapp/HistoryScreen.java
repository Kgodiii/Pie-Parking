package com.example.pieparkingapp;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class MainActivity extends AppCompatActivity {

    private static final String PREFS_NAME = "UserPrefs"; // For storing user info
    RecyclerView recyclerViewHistory;
    List<HistoryItem> historyList;
    HistoryAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        recyclerViewHistory = findViewById(R.id.recyclerViewHistory);
        recyclerViewHistory.setLayoutManager(new LinearLayoutManager(this));

        historyList = new ArrayList<>();
        adapter = new HistoryAdapter(historyList);
        recyclerViewHistory.setAdapter(adapter);

        // For now, simulate logged-in user (REMOVE later once login is integrated)
        SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putInt("userid", 2); // 👈 Replace this manually to test different users
        editor.apply();

        fetchHistoryFromAPI();
    }

    private void fetchHistoryFromAPI() {
        OkHttpClient client = new OkHttpClient();

        // Get stored userId dynamically
        SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        int userId = prefs.getInt("userid", -1);

        if (userId == -1) {
            Toast.makeText(this, "User not logged in. Using default user (ID=2)", Toast.LENGTH_SHORT).show();
            userId = 2; // fallback if not set
        }

        String url = "https://pieparking.co.za/api/transaction?userid=" + userId;
        String token = "Bearer " + BuildConfig.API_KEY;

        Log.d("API_DEBUG", "Fetching data from: " + url);
        Log.d("API_DEBUG", "Using userId: " + userId);

        Request request = new Request.Builder()
                .url(url)
                .addHeader("Authorization", token)
                .build();

        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e("API_ERROR", "Connection failed: " + e.getMessage());
                runOnUiThread(() ->
                        Toast.makeText(MainActivity.this, "Failed to connect to server", Toast.LENGTH_SHORT).show());
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (!response.isSuccessful() || response.body() == null) {
                    Log.e("API_ERROR", "Bad response: " + response.code());
                    return;
                }

                String jsonResponse = response.body().string();
                Log.d("API_RESPONSE", jsonResponse);

                try {
                    Gson gson = new Gson();
                    Type listType = new TypeToken<List<HistoryItem>>() {}.getType();
                    final List<HistoryItem> fetchedHistory = gson.fromJson(jsonResponse, listType);

                    runOnUiThread(() -> {
                        historyList.clear();
                        historyList.addAll(fetchedHistory);
                        adapter.notifyDataSetChanged();

                        if (fetchedHistory.isEmpty()) {
                            Toast.makeText(MainActivity.this, "No transactions found.", Toast.LENGTH_SHORT).show();
                        }
                    });

                } catch (Exception e) {
                    Log.e("JSON_ERROR", "Failed to parse: " + e.getMessage());
                    Log.e("JSON_ERROR", "Raw JSON: " + jsonResponse);
                }
            }
        });
    }
}