import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MosallaEntry {
        // Example placeholder data for Xcode preview
        MosallaEntry(
            date: Date(),
            nextPrayerName: "Asr",
            nextPrayerTime: Date().addingTimeInterval(3600),
            previousPrayerTime: Date()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MosallaEntry) -> ()) {
        let entry = MosallaEntry(
            date: Date(),
            nextPrayerName: "Asr",
            nextPrayerTime: Date().addingTimeInterval(3600),
            previousPrayerTime: Date()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MosallaEntry>) -> ()) {
        // Access shared data from Flutter via the configured App Group
        let userDefaults = UserDefaults(suiteName: "group.com.mosalla.app")
        let nextPrayerName = userDefaults?.string(forKey: "next_prayer_name") ?? "Waiting..."
        
        // Flutter sends Int epoch times in milliseconds
        let nextTimeEpoch = userDefaults?.integer(forKey: "next_prayer_time") ?? 0
        let prevTimeEpoch = userDefaults?.integer(forKey: "previous_prayer_time") ?? 0
        
        let nextPrayerTime: Date
        if nextTimeEpoch > 0 {
            nextPrayerTime = Date(timeIntervalSince1970: TimeInterval(nextTimeEpoch) / 1000.0)
        } else {
            nextPrayerTime = Date().addingTimeInterval(3600)
        }
        
        let previousPrayerTime: Date
        if prevTimeEpoch > 0 {
            previousPrayerTime = Date(timeIntervalSince1970: TimeInterval(prevTimeEpoch) / 1000.0)
        } else {
            previousPrayerTime = Date()
        }

        let entry = MosallaEntry(
            date: Date(),
            nextPrayerName: nextPrayerName,
            nextPrayerTime: nextPrayerTime,
            previousPrayerTime: previousPrayerTime
        )

        // Policy to refresh exactly when the countdown hits zero
        let timeline = Timeline(entries: [entry], policy: .after(nextPrayerTime))
        completion(timeline)
    }
}

struct MosallaEntry: TimelineEntry {
    let date: Date
    let nextPrayerName: String
    let nextPrayerTime: Date
    let previousPrayerTime: Date
}

struct MosallaWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if family == .accessoryCircular {
            circularLockScreenView
        } else {
            homeScreenView
        }
    }
    
    var circularLockScreenView: some View {
        VStack {
            ProgressView(timerInterval: entry.previousPrayerTime...entry.nextPrayerTime, countsDown: true) {
                Text(entry.nextPrayerName)
            } currentValueLabel: {
                Text(entry.nextPrayerName)
                    .font(.system(size: 9, weight: .bold))
            }
            .progressViewStyle(.circular)
            .tint(.teal)
        }
        .widgetBackground(Color.clear)
    }
    
    var homeScreenView: some View {
        VStack(spacing: 8) {
            Text(entry.nextPrayerName)
                .font(.headline)
                .foregroundColor(.teal)
                .bold()
            
            ProgressView(timerInterval: entry.previousPrayerTime...entry.nextPrayerTime, countsDown: true) {
                EmptyView()
            } currentValueLabel: {
                Text("") 
            }
            .progressViewStyle(.circular)
            .tint(.teal)
        }
        .padding()
        .widgetBackground(Color(UIColor.systemBackground))
    }
}

extension View {
    @ViewBuilder
    func widgetBackground<V: View>(_ backgroundView: V) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            self.background(backgroundView)
        }
    }
}

struct MosallaWidget: Widget {
    let kind: String = "MosallaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MosallaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mosalla Countdown")
        .description("Circular countdown to the next prayer time.")
        .supportedFamilies([.accessoryCircular, .systemSmall, .systemMedium])
    }
}


