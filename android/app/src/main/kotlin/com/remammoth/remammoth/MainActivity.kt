package com.remammoth.remammoth

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    private var lastAppliedScheme: String? = null

    private val allAliases = listOf(
        "com.remammoth.remammoth.MainActivityDefaultBlue",
        "com.remammoth.remammoth.MainActivityFireIce",
        "com.remammoth.remammoth.MainActivityDarkMode",
        "com.remammoth.remammoth.MainActivityJungle",
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setBackgroundDrawable(ColorDrawable(schemeBackgroundColor()))
        applyLauncherIconIfNeeded()
    }

    override fun onStop() {
        super.onStop()
        applyLauncherIconIfNeeded()
    }

    private fun applyLauncherIconIfNeeded() {
        val scheme = storedSchemeName()
        if (scheme == lastAppliedScheme) return
        try {
            applyLauncherIcon(scheme)
            lastAppliedScheme = scheme
        } catch (_: Exception) {}
    }

    private fun applyLauncherIcon(scheme: String) {
        val target = "com.remammoth.remammoth." + when (scheme) {
            "fireIce"  -> "MainActivityFireIce"
            "darkMode" -> "MainActivityDarkMode"
            "jungle"   -> "MainActivityJungle"
            else       -> "MainActivityDefaultBlue"
        }
        packageManager.setComponentEnabledSetting(
            ComponentName(packageName, target),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
        for (alias in allAliases) {
            if (alias != target) {
                packageManager.setComponentEnabledSetting(
                    ComponentName(packageName, alias),
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP,
                )
            }
        }
    }

    private fun storedSchemeName(): String {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        return prefs.getString("flutter.color_scheme", null) ?: "defaultBlue"
    }

    private fun schemeBackgroundColor(): Int {
        return when (storedSchemeName()) {
            "fireIce"  -> 0xFF6EE9EF.toInt()
            "darkMode" -> 0xFF180A0A.toInt()
            "jungle"   -> 0xFF9CB080.toInt()
            else       -> 0xFF023B67.toInt()
        }
    }
}
