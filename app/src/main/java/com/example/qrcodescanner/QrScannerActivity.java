package com.example.qrcodescanner;

import android.Manifest;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;
import android.widget.Toolbar;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;q

import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.budiyev.android.codescanner.CodeScanner;
import com.budiyev.android.codescanner.CodeScannerView;
import com.budiyev.android.codescanner.DecodeCallback;
import com.google.zxing.Result;
import com.karumi.dexter.Dexter;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionDeniedResponse;
import com.karumi.dexter.listener.PermissionGrantedResponse;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.single.PermissionListener;

import java.io.IOException;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;


public class QrScannerActivity extends AppCompatActivity {
    private Toolbar toolbar;;
    private Button payBtn;
    CodeScanner codeScanner;
    CodeScannerView scannerView;
    private String activeSessionId = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });


        scannerView = findViewById(R.id.scanner_view);
        codeScanner = new CodeScanner(this,scannerView);

        // Decodes the qr code
        codeScanner.setDecodeCallback(new DecodeCallback() {
            @Override
            public void onDecoded(@NonNull Result result) {
                runOnUiThread(() -> {
                    String qrData = result.getText();

                    if (activeSessionId == null){
                        // starts the session when there aren't any active
                        sendSessionRequest(qrData);
                    } else {
                        // ends the active session when qr code is scanned again
                        endSessionRequest(activeSessionId);
                    }

                });
            }
        });


    // Button start the payment activity
    payBtn.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            startActivity(new Intent(getApplicationContext(), mainIndex.class)); /*add next page name here*/
        }
     });

    // makes it possible to scan more than one Qr code
        scannerView.setOnClickListener(new View.OnClickListener() {
           @Override
           public void onClick(View v) {
               codeScanner.startPreview();
           }
       });
    }

    // method to capture the qr code image
    @Override
    protected void onResume(){
        super.onResume();
        requestCameraPermission();
    }

    // requests for the camera permission
    private void requestCameraPermission() {
        Dexter.withActivity(this).withPermission(Manifest.permission.CAMERA).withListener(new PermissionListener() {
            @Override
            public void onPermissionGranted(PermissionGrantedResponse permissionGrantedResponse) {
                codeScanner.startPreview();
            }

            @Override
            public void onPermissionDenied(PermissionDeniedResponse permissionDeniedResponse) {
                Toast.makeText(QrScannerActivity.this, "Camera Permission is required", Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onPermissionRationaleShouldBeShown(PermissionRequest permissionRequest, PermissionToken permissionToken) {
                permissionToken.continuePermissionRequest();
            }
        }).check();
    }
    // http GET request to start the parking session
    private void sendSessionRequest(String qrData) {
        new Thread(() -> {
            OkHttpClient client = new OkHttpClient();

            // backend endpoint get request to start session
            String url = "https://pieparking.co.za/api/session" + qrData;

            Request request = new Request.Builder()
                    .url(url)
                    .get()
                    .build();

            try (Response response = client.newCall(request).execute()) {
                if (response.isSuccessful()) {
                    // saves the session id for when it has to end
                    activeSessionId = qrData;
                    runOnUiThread(() ->
                            Toast.makeText(QrScannerActivity.this, "Welcome. Your session has started", Toast.LENGTH_SHORT).show()
                    );
                } else {
                    runOnUiThread(() ->
                            Toast.makeText(QrScannerActivity.this, "Failed: " + response.code(), Toast.LENGTH_SHORT).show()
                    );
                }
            } catch (IOException e) {
                runOnUiThread(() ->
                        Toast.makeText(QrScannerActivity.this, "Error: " + e.getMessage(), Toast.LENGTH_SHORT).show()
                );
            }
        }).start();
    }

    //http GET request to end the parking session when its paid
    private void endSessionRequest(String sessionId) {
        new Thread(() -> {
            OkHttpClient client = new OkHttpClient();
            // api request that checks if session is paid to end it
            String url = "https://pieprking.co.za/api/session?id=1" + sessionId;

            Request request = new Request.Builder()
                    .url(url)
                    .get()
                    .build();

            try (Response response = client.newCall(request).execute()) {
                if (response.isSuccessful()) {
                    runOnUiThread(() ->
                            Toast.makeText(QrScannerActivity.this, "Thank you for using Pie Parking", Toast.LENGTH_SHORT).show()
                    );
                    // Clears the session that was saved when the user scanned
                    activeSessionId = null;
                } else {
                    runOnUiThread(() ->
                            Toast.makeText(QrScannerActivity.this, "Please make payment to end session", Toast.LENGTH_SHORT).show()
                    );
                }
            } catch (IOException e) {
                runOnUiThread(() ->
                        Toast.makeText(QrScannerActivity.this, "Error: " + e.getMessage(), Toast.LENGTH_SHORT).show()
                );
            }
        }).start();
    }


}


