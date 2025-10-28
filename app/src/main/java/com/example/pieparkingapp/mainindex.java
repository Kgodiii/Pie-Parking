package com.example.pieparkingapp;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

public class mainIndex extends AppCompatActivity {

    private TextView savedCardText;
    private Button addCardButton;

    // Launcher to open PaymentMethodsActivity and get result
    private final ActivityResultLauncher<Intent> paymentMethodLauncher =
            registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), result -> {
                if (result.getResultCode() == RESULT_OK && result.getData() != null) {
                    String cardNickname = result.getData().getStringExtra("cardNickname");
                    if (cardNickname != null && !cardNickname.isEmpty()) {
                        savedCardText.setText(getString(R.string.saved_card_label, cardNickname));
                    }
                }
            });

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_mainindex);

        initViews();
        setupListeners();
    }

    private void initViews() {
        savedCardText = findViewById(R.id.savedCardText);
        addCardButton = findViewById(R.id.addCardButton);
    }

    private void setupListeners() {
        addCardButton.setOnClickListener(v -> {
            Intent intent = new Intent(mainIndex.this, PaymentMethodsActivity.class);
            paymentMethodLauncher.launch(intent);
        });

        savedCardText.setOnClickListener(v -> {
            Intent intent = new Intent(mainIndex.this, PaymentPage.class);
            startActivity(intent);
   });

    }
}