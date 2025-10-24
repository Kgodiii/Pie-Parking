package com.example.Home_Screen

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.home_screen.databinding.ActivityScanEntryBinding

class ScanEntryActivity : AppCompatActivity() {

    private lateinit var binding: ActivityScanEntryBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityScanEntryBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.btnPayNow.setOnClickListener {
            Toast.makeText(this, "Redirecting to payment...", Toast.LENGTH_SHORT).show()
        }
    }
}

