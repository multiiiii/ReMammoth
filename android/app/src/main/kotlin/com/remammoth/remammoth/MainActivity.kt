package com.remammoth.remammoth

import android.content.Context
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setBackgroundDrawable(ColorDrawable(schemeBackgroundColor()))
    }

    private fun schemeBackgroundColor(): Int {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        return when (prefs.getString("flutter.color_scheme", null)) {
            "fireIce"  -> 0xFF6EE9EF.toInt()
            "darkMode" -> 0xFF180A0A.toInt()
            "jungle"   -> 0xFF9CB080.toInt()
            else       -> 0xFF023B67.toInt()
        }
    }
}
