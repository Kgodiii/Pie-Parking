package com.example.pieparkingapp;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;

import java.util.ArrayList;
import java.util.List;

public class PaymentMethodActivity extends AppCompatActivity {

    private TextInputEditText cardNumberInput, expiryDateInput, cvvInput, nicknameInput;
    private AutoCompleteTextView countrySpinner;
    private MaterialButton saveCardButton;
    private ImageView backArrow;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_payment_method);

        // Initialize views
        cardNumberInput = findViewById(R.id.cardNumberInput);
        expiryDateInput = findViewById(R.id.expiryDateInput);
        cvvInput = findViewById(R.id.cvvInput);
        nicknameInput = findViewById(R.id.nicknameInput);
        countrySpinner = findViewById(R.id.countrySpinner);
        saveCardButton = findViewById(R.id.saveCardButton);
        backArrow = findViewById(R.id.backArrow);

        // Setup country dropdown
        setupCountryDropdown();

        // Setup card number formatting
        setupCardNumberFormatting();

        // Setup expiry date formatting
        setupExpiryDateFormatting();

        // Back arrow click listener
        backArrow.setOnClickListener(v -> finish());

        // Save card button click listener
        saveCardButton.setOnClickListener(v -> saveCard());
    }

    private void setupCountryDropdown() {
        List<String> countries = new ArrayList<>();
        countries.add("South Africa");
        countries.add("United States");
        countries.add("United Kingdom");
        countries.add("Canada");
        countries.add("Australia");
        countries.add("Germany");
        countries.add("France");
        countries.add("Italy");
        countries.add("Spain");
        countries.add("Netherlands");
        countries.add("India");
        countries.add("China");
        countries.add("Japan");
        countries.add("Brazil");
        countries.add("Mexico");

        ArrayAdapter<String> adapter = new ArrayAdapter<>(
                this,
                android.R.layout.simple_dropdown_item_1line,
                countries
        );
        countrySpinner.setAdapter(adapter);
        countrySpinner.setText("South Africa", false);
    }

    private void setupCardNumberFormatting() {
        cardNumberInput.addTextChangedListener(new TextWatcher() {
            private static final int TOTAL_SYMBOLS = 19; // 16 digits + 3 spaces
            private static final int TOTAL_DIGITS = 16;
            private static final int DIVIDER_MODULO = 5;
            private static final int DIVIDER_POSITION = DIVIDER_MODULO - 1;
            private static final char DIVIDER = ' ';

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {}

            @Override
            public void afterTextChanged(Editable s) {
                if (!isInputCorrect(s, TOTAL_SYMBOLS, DIVIDER_MODULO, DIVIDER)) {
                    s.replace(0, s.length(), buildCorrectString(getDigitArray(s, TOTAL_DIGITS), DIVIDER_POSITION, DIVIDER));
                }
            }

            private boolean isInputCorrect(Editable s, int totalSymbols, int dividerModulo, char divider) {
                boolean isCorrect = s.length() <= totalSymbols;
                for (int i = 0; i < s.length(); i++) {
                    if (i > 0 && (i + 1) % dividerModulo == 0) {
                        isCorrect &= divider == s.charAt(i);
                    } else {
                        isCorrect &= Character.isDigit(s.charAt(i));
                    }
                }
                return isCorrect;
            }

            private String buildCorrectString(char[] digits, int dividerPosition, char divider) {
                final StringBuilder formatted = new StringBuilder();

                for (int i = 0; i < digits.length; i++) {
                    if (digits[i] != 0) {
                        formatted.append(digits[i]);
                        if ((i > 0) && (i < (digits.length - 1)) && (((i + 1) % dividerPosition) == 0)) {
                            formatted.append(divider);
                        }
                    }
                }

                return formatted.toString();
            }

            private char[] getDigitArray(final Editable s, final int size) {
                char[] digits = new char[size];
                int index = 0;
                for (int i = 0; i < s.length() && index < size; i++) {
                    char current = s.charAt(i);
                    if (Character.isDigit(current)) {
                        digits[index] = current;
                        index++;
                    }
                }
                return digits;
            }
        });
    }

    private void setupExpiryDateFormatting() {
        expiryDateInput.addTextChangedListener(new TextWatcher() {
            private String current = "";

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (!s.toString().equals(current)) {
                    String clean = s.toString().replaceAll("[^\\d]", "");
                    if (clean.length() >= 2) {
                        String month = clean.substring(0, 2);
                        String year = clean.substring(2);
                        current = month + (year.length() > 0 ? "/" + year : "");
                    } else {
                        current = clean;
                    }

                    expiryDateInput.removeTextChangedListener(this);
                    expiryDateInput.setText(current);
                    expiryDateInput.setSelection(current.length());
                    expiryDateInput.addTextChangedListener(this);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    private void saveCard() {
        // Get input values
        String cardNumber = cardNumberInput.getText().toString().replaceAll("\\s", "");
        String expiryDate = expiryDateInput.getText().toString();
        String cvv = cvvInput.getText().toString();
        String nickname = nicknameInput.getText().toString();
        String country = countrySpinner.getText().toString();

        // Validate inputs
        if (cardNumber.isEmpty() || cardNumber.length() != 16) {
            Toast.makeText(this, "Please enter a valid 16-digit card number", Toast.LENGTH_SHORT).show();
            return;
        }

        if (expiryDate.isEmpty() || expiryDate.length() != 5) {
            Toast.makeText(this, "Please enter expiry date in MM/YY format", Toast.LENGTH_SHORT).show();
            return;
        }

        // Validate expiry date
        String[] parts = expiryDate.split("/");
        if (parts.length != 2) {
            Toast.makeText(this, "Invalid expiry date format", Toast.LENGTH_SHORT).show();
            return;
        }

        int month = Integer.parseInt(parts[0]);
        if (month < 1 || month > 12) {
            Toast.makeText(this, "Invalid month in expiry date", Toast.LENGTH_SHORT).show();
            return;
        }

        if (cvv.isEmpty() || cvv.length() < 3 || cvv.length() > 4) {
            Toast.makeText(this, "Please enter a valid CVV", Toast.LENGTH_SHORT).show();
            return;
        }

        if (country.isEmpty()) {
            Toast.makeText(this, "Please select a country", Toast.LENGTH_SHORT).show();
            return;
        }

        // Return data to main activity
        Intent resultIntent = new Intent();
        resultIntent.putExtra("cardNumber", cardNumber);
        resultIntent.putExtra("expiryDate", expiryDate);
        resultIntent.putExtra("cvv", cvv);
        resultIntent.putExtra("nickname", nickname);
        resultIntent.putExtra("country", country);
        setResult(RESULT_OK, resultIntent);
        finish();

        Toast.makeText(this, "Card saved successfully!", Toast.LENGTH_SHORT).show();
   }
}