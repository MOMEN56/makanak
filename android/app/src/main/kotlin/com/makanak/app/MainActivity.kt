package com.makanak.app

import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val installReferrerChannelName = "makanak/install_referrer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            installReferrerChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstallReferrer" -> readInstallReferrer(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun readInstallReferrer(result: MethodChannel.Result) {
        val client = InstallReferrerClient.newBuilder(this).build()
        var hasReplied = false

        fun finish(referrer: String?) {
            if (hasReplied) return

            hasReplied = true
            result.success(referrer)
            runCatching { client.endConnection() }
        }

        try {
            client.startConnection(
                object : InstallReferrerStateListener {
                    override fun onInstallReferrerSetupFinished(responseCode: Int) {
                        if (responseCode != InstallReferrerClient.InstallReferrerResponse.OK) {
                            finish(null)
                            return
                        }

                        val referrer =
                            runCatching {
                                client.installReferrer.installReferrer
                            }.getOrNull()

                        finish(referrer)
                    }

                    override fun onInstallReferrerServiceDisconnected() {
                        finish(null)
                    }
                },
            )
        } catch (_: Exception) {
            finish(null)
        }
    }
}
