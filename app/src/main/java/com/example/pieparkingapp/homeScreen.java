package com.example.pieparkingapp;

import android.os.Bundle;
import android.widget.Button;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;

public class homeScreen extends AppCompatActivity {

    private Button payNowBtn;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_home_screen);

        payNowBtn = findViewById(R.id.payNowBtn); // Match XML ID

        payNowBtn.setOnClickListener(v -> {
            Toast.makeText(homeScreen.this, "Payment Fun coming soon!", Toast.LENGTH_SHORT).show();
        });

    }
}