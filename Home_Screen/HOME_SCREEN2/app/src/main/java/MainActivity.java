package com.example.home_screen;

import android.os.Bundle;
import android.widget.Button;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    Button payNowBtn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main); // Only once

        payNowBtn = findViewById(R.id.payNowBtn); // Match XML ID

        payNowBtn.setOnClickListener(v -> {
            Toast.makeText(MainActivity.this, "Payment Fun coming soon!", Toast.LENGTH_SHORT).show();
        });
    }
}
