package com.example.homescreen;

import android.os.Bundle;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

public class HomeActivity extends AppCompatActivity {

    private Button payNowButton;
    private ImageView menuIcon;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        payNowButton = findViewById(R.id.payNowButton);
        menuIcon = findViewById(R.id.menuIcon);

        // Handle Pay Now button
        payNowButton.setOnClickListener(v ->
                Toast.makeText(HomeActivity.this, "Redirecting to payment...", Toast.LENGTH_SHORT).show()
        );

        // Handle Menu icon
        menuIcon.setOnClickListener(v ->
                Toast.makeText(HomeActivity.this, "Menu clicked", Toast.LENGTH_SHORT).show()
        );
    }
}