package com.cingulo.device_unlock

import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class DeviceUnlockPlugin(registrar: Registrar) : MethodCallHandler {

    private val deviceUnlockManager = DeviceUnlockManager(registrar.activity())
    private val context: Context;

    init {
        registrar.addActivityResultListener(deviceUnlockManager)
        context = registrar.context();
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "request") {
            request(call, result)
        } else if (call.method == "gotoSettings") {
            openSettings()
        } else {
            result.notImplemented()
        }
    }

    private fun request(call: MethodCall, result: Result) {
        deviceUnlockManager.authenticate(call, result)
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "device_unlock")
            channel.setMethodCallHandler(DeviceUnlockPlugin(registrar))
        }
    }

    /**
     *  This method opens the device security settings to setup the Authentication for the device.
     */
    private fun openSettings() {
        var intent: Intent = Intent(Settings.ACTION_SECURITY_SETTINGS)
        context.startActivity(intent)
    }

}
