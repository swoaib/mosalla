package x.sohaibahmed.mosalla

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_widget).apply {
                val nextName = widgetData.getString("next_prayer_name", "Waiting...") ?: "Waiting..."
                val nextTime = widgetData.getLong("next_prayer_time", 0L)
                
                setTextViewText(R.id.prayer_name, nextName)

                if (nextTime > 0) {
                    val remainingMs = nextTime - System.currentTimeMillis()
                    val expectedBase = android.os.SystemClock.elapsedRealtime() + remainingMs
                    setChronometer(R.id.time_countdown, expectedBase, null, true)
                    
                    // Android 7.0+ API 24 enables count down
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                        setChronometerCountDown(R.id.time_countdown, true)
                    }
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
