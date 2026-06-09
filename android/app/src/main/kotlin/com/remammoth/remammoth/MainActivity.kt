package com.remammoth.remammoth

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    private var lastAppliedScheme: String? = null

    private val schemeAliases = mapOf(
        "fireIce"  to "com.remammoth.remammoth.MainActivityFireIce",
        "darkMode" to "com.remammoth.remammoth.MainActivityDarkMode",
        "jungle"   to "com.remammoth.remammoth.MainActivityJungle",
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
        val targetAlias = schemeAliases[scheme]

        if (targetAlias == null) {
            // Classic Blue: show MainActivity's own launcher entry, hide all aliases
            setComponent(packageName, PackageManager.COMPONENT_ENABLED_STATE_ENABLED)
            for (alias in schemeAliases.values) {
                setComponent(alias, PackageManager.COMPONENT_ENABLED_STATE_DISABLED)
            }
        } else {
            // Non-default: show the alias icon, hide MainActivity's launcher entry
            // Enable target alias first so the icon is never absent from the launcher
            setComponent(targetAlias, PackageManager.COMPONENT_ENABLED_STATE_ENABLED)
            for ((_, alias) in schemeAliases) {
                if (alias != targetAlias) {
                    setComponent(alias, PackageManager.COMPONENT_ENABLED_STATE_DISABLED)
                }
            }
            setComponent(packageName, PackageManager.COMPONENT_ENABLED_STATE_DISABLED)
        }
    }

    private fun setComponent(name: String, state: Int) {
        packageManager.setComponentEnabledSetting(
            ComponentName(packageName, name),
            state,
            PackageManager.DONT_KILL_APP,
        )
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
