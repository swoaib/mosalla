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
        let userDefaults = UserDefaults(suiteName: "group.com.mosalla.app")
        let scheduleJson = userDefaults?.string(forKey: "prayers_schedule") ?? ""
        let baselineEpoch = userDefaults?.integer(forKey: "baseline_previous_time") ?? 0
        
        var entries: [MosallaEntry] = []
        let now = Date()
        
        if let data = scheduleJson.data(using: .utf8),
           let scheduleArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
           
            var lastKnownTime = baselineEpoch > 0 ? Date(timeIntervalSince1970: TimeInterval(baselineEpoch) / 1000.0) : now
            
            for index in 0..<scheduleArray.count {
                let dict = scheduleArray[index]
                if let name = dict["name"] as? String,
                   let timeEpoch = dict["time"] as? Int {
                    
                    let nextPrayerTime = Date(timeIntervalSince1970: TimeInterval(timeEpoch) / 1000.0)
                    
                    // The 'date' to render this entry is exactly when the previous prayer finishes.
                    // But the first valid entry should start rendering right now.
                    let entryDate = entries.isEmpty ? now : lastKnownTime
                    
                    // Ensure the target countdown is actually in the future!
                    if nextPrayerTime > entryDate {
                        let entry = MosallaEntry(
                            date: entryDate,
                            nextPrayerName: name,
                            nextPrayerTime: nextPrayerTime,
                            previousPrayerTime: lastKnownTime
                        )
                        entries.append(entry)
                        lastKnownTime = nextPrayerTime
                    } else {
                        // Skip expired entry but update lastKnownTime so the next entry has the correct start point for its progress view
                        lastKnownTime = nextPrayerTime
                    }
                }
            }
        }
        
        // Fallback strategy if JSON parses empty or fails (legacy handling)
        if entries.isEmpty {
            let nextPrayerName = userDefaults?.string(forKey: "next_prayer_name") ?? "Waiting..."
            let nextTimeEpoch = userDefaults?.integer(forKey: "next_prayer_time") ?? 0
            let prevTimeEpoch = userDefaults?.integer(forKey: "previous_prayer_time") ?? 0
            
            let nextPrayerTime = nextTimeEpoch > 0 ? Date(timeIntervalSince1970: TimeInterval(nextTimeEpoch) / 1000.0) : now.addingTimeInterval(3600)
            let previousPrayerTime = prevTimeEpoch > 0 ? Date(timeIntervalSince1970: TimeInterval(prevTimeEpoch) / 1000.0) : now
            
            let entry = MosallaEntry(
                date: now,
                nextPrayerName: nextPrayerName,
                nextPrayerTime: nextPrayerTime,
                previousPrayerTime: previousPrayerTime
            )
            entries.append(entry)
        }

        // We use `.atEnd` so iOS proactively wakes the extension up to refresh 
        // perfectly when we run out of scheduled timeline entries!
        let timeline = Timeline(entries: entries, policy: .atEnd)
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
                Text(entry.nextPrayerName.localizedPrayerName)
            } currentValueLabel: {
                Text(entry.nextPrayerName.localizedPrayerName)
                    .font(.system(size: 9, weight: .bold))
            }
            .progressViewStyle(.circular)
            .tint(.teal)
        }
        .widgetBackground(Color.clear)
    }
    
    var homeScreenView: some View {
        VStack(spacing: 8) {
            Text(entry.nextPrayerName.localizedPrayerName)
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

extension String {
    var localizedPrayerName: String {
        let isJapanese = Locale.current.language.languageCode?.identifier == "ja" || Locale.current.languageCode == "ja"
        
        switch self {
        case "Fajr": return isJapanese ? "ファジュル" : "Fajr"
        case "Sunrise": return isJapanese ? "日の出" : "Sunrise"
        case "Duhr": return isJapanese ? "ズフル" : "Duhr"
        case "Asr": return isJapanese ? "アスル" : "Asr"
        case "Maghrib": return isJapanese ? "マグリブ" : "Maghrib"
        case "Isha": return isJapanese ? "イシャー" : "Isha"
        case "Jumma": return isJapanese ? "ジュムア" : "Jumma"
        default: return self
        }
    }
}


