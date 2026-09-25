package io.github.jirugutema.tooran

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * FlutterFragmentActivity (not FlutterActivity) is required by local_auth.
 *
 * Also receives text shared from other apps (ACTION_SEND, text/plain) and hands it
 * to Dart over the `tooran/share` MethodChannel:
 *  - Dart -> native `getInitialSharedText`: returns the pending shared text (or null)
 *    exactly once.
 *  - native -> Dart `sharedText(String)`: pushed when a share arrives while the app is
 *    already running. If Dart has no handler yet, the text is kept for
 *    `getInitialSharedText` instead.
 */
class MainActivity : FlutterFragmentActivity() {

    private var shareChannel: MethodChannel? = null
    private var pendingSharedText: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // Only read the launch intent on a fresh start; after a recreation the text was
        // already captured (and possibly consumed) by the previous instance.
        if (savedInstanceState == null && !launchedFromHistory(intent)) {
            pendingSharedText = extractSharedText(intent)
        } else {
            pendingSharedText = savedInstanceState?.getString(STATE_PENDING_SHARE)
        }
        super.onCreate(savedInstanceState)
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        pendingSharedText?.let { outState.putString(STATE_PENDING_SHARE, it) }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        shareChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHARE_CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialSharedText" -> {
                        val text = pendingSharedText
                        pendingSharedText = null
                        result.success(text)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        shareChannel?.setMethodCallHandler(null)
        shareChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Keep getIntent() current (home_widget and other plugins read it).
        setIntent(intent)

        val text = extractSharedText(intent) ?: return
        val channel = shareChannel
        if (channel == null) {
            pendingSharedText = text
            return
        }
        channel.invokeMethod("sharedText", text, object : MethodChannel.Result {
            override fun success(result: Any?) {}

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                pendingSharedText = text
            }

            override fun notImplemented() {
                // Dart has not registered its handler yet; let getInitialSharedText pick it up.
                pendingSharedText = text
            }
        })
    }

    private fun launchedFromHistory(intent: Intent?): Boolean =
        intent != null && (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0

    private fun extractSharedText(intent: Intent?): String? {
        if (intent == null || intent.action != Intent.ACTION_SEND) return null
        val type = intent.type
        if (type != null && !type.startsWith("text/")) return null

        val text = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()?.trim()
        val subject = intent.getCharSequenceExtra(Intent.EXTRA_SUBJECT)?.toString()?.trim()

        val combined = when {
            text.isNullOrEmpty() -> subject
            subject.isNullOrEmpty() || subject == text || text.contains(subject) -> text
            else -> "$subject\n$text"
        }
        return combined?.takeIf { it.isNotEmpty() }
    }

    companion object {
        private const val SHARE_CHANNEL = "tooran/share"
        private const val STATE_PENDING_SHARE = "tooran.pendingSharedText"
    }
}
