package com.example.pieparkingapp;

import android.os.Bundle;
import android.text.InputType;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

public class SignInActivity extends AppCompatActivity {
    private EditText usernameEditText, passwordEditText;
    private Button signInButton;
    private ImageView eyeIcon;
    private TextView forgotPassword;
    private boolean passwordVisible = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);

        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayShowTitleEnabled(false); // Hide default title
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        // Bind views by ID
        usernameEditText = findViewById(R.id.username);
        passwordEditText = findViewById(R.id.password);
        signInButton = findViewById(R.id.sign_in_button);
        eyeIcon = findViewById(R.id.eye_icon);
        forgotPassword = findViewById(R.id.forgot_password);

        // Toggle password visibility
        eyeIcon.setOnClickListener(v -> {
            if (passwordVisible) {
                passwordEditText.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
                eyeIcon.setImageResource(android.R.drawable.ic_menu_view); // Placeholder for closed eye
                passwordVisible = false;
            } else {
                passwordEditText.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
                eyeIcon.setImageResource(android.R.drawable.ic_menu_view); // Placeholder for open eye
                passwordVisible = true;
            }
            passwordEditText.setSelection(passwordEditText.length());
        });

        // Forgot password click listener
        forgotPassword.setOnClickListener(v -> {
            Toast.makeText(SignInActivity.this, "Forgot Password clicked", Toast.LENGTH_SHORT).show();
        });

        // Sample sign in button logic
        signInButton.setOnClickListener(v -> {
            String username = usernameEditText.getText().toString().trim();
            String password = passwordEditText.getText().toString();

            if (username.isEmpty() || password.isEmpty()) {
                Toast.makeText(SignInActivity.this, "Please enter all fields.", Toast.LENGTH_SHORT).show();
            } else {
                // TODO: Authenticate user here (API call, local validation, etc.)
                Toast.makeText(SignInActivity.this, "Sign In Pressed", Toast.LENGTH_SHORT).show();
            }
        });
    }
}