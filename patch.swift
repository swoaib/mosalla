--- ios/MosallaWidget/MosallaWidget.swift
+++ ios/MosallaWidget/MosallaWidget.swift
@@ -42,27 +42,16 @@
                     let nextPrayerTime = Date(timeIntervalSince1970: TimeInterval(timeEpoch) / 1000.0)
                     
-                    // The 'date' to render this entry is exactly when the previous prayer finishes.
-                    // But the first entry should start rendering right now.
-                    let entryDate = index == 0 ? now : lastKnownTime
+                    let entryDate = entries.isEmpty ? now : lastKnownTime
                     
-                    // Ensure the target countdown is actually in the future!
                     if nextPrayerTime > entryDate {
                         let entry = MosallaEntry(
                             date: entryDate,
                             nextPrayerName: name,
                             nextPrayerTime: nextPrayerTime,
                             previousPrayerTime: lastKnownTime
                         )
                         entries.append(entry)
-                    } else if index == 0 {
-                        // Edge case: if we are building the first entry but it's expired,
-                        // force it to render from 'now' anyway until the data syncs.
-                        let entry = MosallaEntry(
-                            date: now,
-                            nextPrayerName: name,
-                            nextPrayerTime: nextPrayerTime,
-                            previousPrayerTime: lastKnownTime
-                        )
-                        entries.append(entry)
+                        lastKnownTime = nextPrayerTime
+                    } else {
+                        lastKnownTime = nextPrayerTime
                     }
                     
-                    lastKnownTime = nextPrayerTime
                 }
             }
