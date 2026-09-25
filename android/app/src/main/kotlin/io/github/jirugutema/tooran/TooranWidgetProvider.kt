package io.github.jirugutema.tooran

import android.app.ActivityOptions
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Paint
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundReceiver
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Classic RemoteViews home-screen widget showing up to [MAX_ROWS] tasks.
 *
 * Data is written from Dart with `HomeWidget.saveWidgetData` (keys below) followed by
 * `HomeWidget.updateWidget(qualifiedAndroidName: 'io.github.jirugutema.tooran.TooranWidgetProvider')`.
 *
 *  - `w_title` String, `w_subtitle` String, `w_empty` String, `w_count` int (0..6)
 *  - per row i: `w_item_{i}_text`, `w_item_{i}_id`, `w_item_{i}_cat`, `w_item_{i}_done` (bool),
 *    `w_item_{i}_meta`
 *
 * Clicks:
 *  - checkbox  -> background broadcast `tooran://toggle?cat=<cat>&task=<id>` (Dart interactivity callback)
 *  - row text  -> launch `tooran://task?cat=<cat>&task=<id>`
 *  - header    -> launch `tooran://open`
 *  - "+"       -> launch `tooran://add`
 */
class TooranWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = buildViews(context, appWidgetId, widgetData)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun buildViews(context: Context, appWidgetId: Int, data: SharedPreferences): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_tooran)
        val all = data.all

        val title = all.string("w_title").ifEmpty { context.getString(R.string.widget_default_title) }
        val subtitle = all.string("w_subtitle")
        val empty = all.string("w_empty").ifEmpty { context.getString(R.string.widget_default_empty) }
        val count = all.int("w_count").coerceIn(0, MAX_ROWS)

        views.setTextViewText(R.id.widget_title, title)
        views.setTextViewText(R.id.widget_subtitle, subtitle)
        views.setViewVisibility(R.id.widget_subtitle, if (subtitle.isEmpty()) View.GONE else View.VISIBLE)

        views.setTextViewText(R.id.widget_empty, empty)
        views.setViewVisibility(R.id.widget_empty, if (count == 0) View.VISIBLE else View.GONE)

        val base = requestBase(appWidgetId)
        views.setOnClickPendingIntent(
            R.id.widget_header,
            launchIntent(context, Uri.parse("tooran://open"), base + REQ_OPEN),
        )
        views.setOnClickPendingIntent(
            R.id.widget_add,
            launchIntent(context, Uri.parse("tooran://add"), base + REQ_ADD),
        )

        val inkColor = context.getColor(R.color.widget_ink)
        val mutedColor = context.getColor(R.color.widget_muted)
        val basePaintFlags = Paint(Paint.ANTI_ALIAS_FLAG).flags and Paint.STRIKE_THRU_TEXT_FLAG.inv()

        for (i in 0 until MAX_ROWS) {
            val rowId = ROW_IDS[i]
            if (i >= count) {
                views.setViewVisibility(rowId, View.GONE)
                continue
            }
            views.setViewVisibility(rowId, View.VISIBLE)

            val text = all.string("w_item_${i}_text")
            val taskId = all.string("w_item_${i}_id")
            val catId = all.string("w_item_${i}_cat")
            val done = all.bool("w_item_${i}_done")
            val meta = all.string("w_item_${i}_meta")

            views.setTextViewText(TEXT_IDS[i], text)
            views.setTextColor(TEXT_IDS[i], if (done) mutedColor else inkColor)
            views.setInt(
                TEXT_IDS[i],
                "setPaintFlags",
                if (done) basePaintFlags or Paint.STRIKE_THRU_TEXT_FLAG else basePaintFlags,
            )

            views.setImageViewResource(
                CHECK_IDS[i],
                if (done) R.drawable.widget_checkbox_checked else R.drawable.widget_checkbox_unchecked,
            )
            views.setContentDescription(
                CHECK_IDS[i],
                context.getString(
                    if (done) R.string.widget_mark_not_done else R.string.widget_mark_done,
                    text,
                ),
            )

            views.setTextViewText(META_IDS[i], meta)
            views.setViewVisibility(META_IDS[i], if (meta.isEmpty()) View.GONE else View.VISIBLE)

            val query = "cat=${Uri.encode(catId)}&task=${Uri.encode(taskId)}"
            views.setOnClickPendingIntent(
                CHECK_IDS[i],
                backgroundIntent(context, Uri.parse("tooran://toggle?$query"), base + REQ_TOGGLE + i),
            )
            views.setOnClickPendingIntent(
                TEXT_IDS[i],
                launchIntent(context, Uri.parse("tooran://task?$query"), base + REQ_TASK + i),
            )
        }

        return views
    }

    // Mirrors HomeWidgetLaunchIntent.getActivity, but with a unique request code.
    @Suppress("DEPRECATION") // MODE_BACKGROUND_ACTIVITY_START_ALLOWED (deprecated in API 36)
    private fun launchIntent(context: Context, uri: Uri, requestCode: Int): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            data = uri
            action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        if (Build.VERSION.SDK_INT < 34) {
            return PendingIntent.getActivity(context, requestCode, intent, flags)
        }
        val options = ActivityOptions.makeBasic()
        if (Build.VERSION.SDK_INT >= 35) {
            options.setPendingIntentCreatorBackgroundActivityStartMode(
                ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED,
            )
        } else {
            options.pendingIntentBackgroundActivityStartMode =
                ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED
        }
        return PendingIntent.getActivity(context, requestCode, intent, flags, options.toBundle())
    }

    // Mirrors HomeWidgetBackgroundIntent.getBroadcast, but with a unique request code.
    private fun backgroundIntent(context: Context, uri: Uri, requestCode: Int): PendingIntent {
        val intent = Intent(context, HomeWidgetBackgroundReceiver::class.java).apply {
            data = uri
            action = HOME_WIDGET_BACKGROUND_ACTION
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getBroadcast(context, requestCode, intent, flags)
    }

    private fun Map<String, *>.string(key: String): String = (this[key] as? String) ?: ""

    private fun Map<String, *>.int(key: String): Int = when (val v = this[key]) {
        is Number -> v.toInt()
        is String -> v.toIntOrNull() ?: 0
        else -> 0
    }

    private fun Map<String, *>.bool(key: String): Boolean = when (val v = this[key]) {
        is Boolean -> v
        is Number -> v.toInt() != 0
        is String -> v.equals("true", ignoreCase = true)
        else -> false
    }

    companion object {
        private const val MAX_ROWS = 6
        private const val HOME_WIDGET_BACKGROUND_ACTION = "es.antonborri.home_widget.action.BACKGROUND"

        // Request codes: each widget instance gets its own block of 100.
        private const val REQ_OPEN = 0
        private const val REQ_ADD = 1
        private const val REQ_TOGGLE = 10 // 10..15
        private const val REQ_TASK = 20 // 20..25

        private fun requestBase(appWidgetId: Int) = 1000 + appWidgetId * 100

        private val ROW_IDS = intArrayOf(
            R.id.row_0, R.id.row_1, R.id.row_2, R.id.row_3, R.id.row_4, R.id.row_5,
        )
        private val CHECK_IDS = intArrayOf(
            R.id.row_0_check, R.id.row_1_check, R.id.row_2_check,
            R.id.row_3_check, R.id.row_4_check, R.id.row_5_check,
        )
        private val TEXT_IDS = intArrayOf(
            R.id.row_0_text, R.id.row_1_text, R.id.row_2_text,
            R.id.row_3_text, R.id.row_4_text, R.id.row_5_text,
        )
        private val META_IDS = intArrayOf(
            R.id.row_0_meta, R.id.row_1_meta, R.id.row_2_meta,
            R.id.row_3_meta, R.id.row_4_meta, R.id.row_5_meta,
        )
    }
}
