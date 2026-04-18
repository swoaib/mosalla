const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const admin = require("firebase-admin");
const { DateTime } = require("luxon");
const SunCalc = require("suncalc");

admin.initializeApp();

exports.checkPrayerTimes = onSchedule("* * * * *", async (event) => {
  const db = admin.firestore();
  
  // We assume the mosallas operate in a specific timezone, e.g. Asia/Tokyo
  // Adjust if the deployment target differs.
  const now = DateTime.now().setZone("Asia/Tokyo");
  const monthDocId = now.toFormat("MM-yyyy");
  const dayKey = now.toFormat("dd");
  const oldTodayDocId = now.toFormat("dd-MM-yyyy");

  const mosallasSnapshot = await db.collection("mosalla").get();

  const prayerKeys = [
    'Fajr', 
    'Duhr', 
    'Asr', 
    'Maghrib', 
    'Isha'
  ];

  for (const mosallaDoc of mosallasSnapshot.docs) {
    const mosallaId = mosallaDoc.id;
    const mosallaName = mosallaDoc.data().name || "Mosalla";
    
    let prayerDataForToday = null;
    
    // New Monthly Schema
    const monthDoc = await db.collection("mosalla").doc(mosallaId).collection("prayer_months").doc(monthDocId).get();
    if (monthDoc.exists) {
      const monthData = monthDoc.data();
      prayerDataForToday = monthData[dayKey];
    }
    
    // Fallback to old Daily Schema if not found in Monthly Schema
    if (!prayerDataForToday) {
      const prayerDoc = await db.collection("mosalla").doc(mosallaId).collection("prayer_times").doc(oldTodayDocId).get();
      if (prayerDoc.exists) {
        prayerDataForToday = prayerDoc.data();
      }
    }
    
    if (!prayerDataForToday) {
      continue;
    }

    const data = prayerDataForToday;
    const systemNow = new Date();
    // Check if any prayer time corresponds to the current minute
    for (const key of prayerKeys) {
      if (data[key]) {
        const prayerTime = data[key].toDate(); // Firestore Timestamp to JS Date
        
        // Difference in milliseconds
        const diff = systemNow.getTime() - prayerTime.getTime();
        
        // If the prayer time was exactly within the last 60 seconds (1 minute),
        // we fire the notification.
        if (diff >= 0 && diff < 60000) {
          const topic = `mosalla_${mosallaId}_prayers`;
          const prayerName = key; 
          
          const timeString = DateTime.fromJSDate(prayerTime).setZone("Asia/Tokyo").toFormat("HH:mm");
          const title = `${prayerName} at ${timeString}`;
          const body = mosallaName;

          const payload = {
            notification: {
              title: title,
              body: body,
            },
            topic: topic
          };

          try {
            await getMessaging().send(payload);
            console.log(`Successfully sent message to topic ${topic} for ${key}`);
          } catch (error) {
            console.error(`Error sending message for topic ${topic}:`, error);
          }
        }
      }
    }

    // --- Automatic Sunrise Notification ---
    const lat = mosallaDoc.data().latitude;
    const lng = mosallaDoc.data().longitude;

    if (lat && lng) {
      const times = SunCalc.getTimes(systemNow, lat, lng);
      const sunriseTime = times.sunrise; // JS Date object

      // Check if sunrise corresponds to the current minute
      const diffSunrise = systemNow.getTime() - sunriseTime.getTime();

      if (diffSunrise >= 0 && diffSunrise < 60000) {
        const topic = `mosalla_${mosallaId}_prayers`;
        const timeString = DateTime.fromJSDate(sunriseTime).setZone("Asia/Tokyo").toFormat("HH:mm");
        
        const payload = {
          notification: {
            title: `Sunrise at ${timeString}`,
            body: 'the sun is rising!',
          },
          topic: topic
        };

        try {
          await getMessaging().send(payload);
          console.log(`Successfully sent sunrise message to topic ${topic} for ${mosallaName}`);
        } catch (error) {
          console.error(`Error sending sunrise message for topic ${topic}:`, error);
        }
      }
    }
  }
});

exports.notifyNewEvent = onDocumentCreated("mosalla/{mosallaId}/events/{eventId}", async (event) => {
  const mosallaId = event.params.mosallaId;
  const newEventData = event.data.data();

  if (!newEventData) return;

  // Fetch mosque name to use as title
  const db = admin.firestore();
  const mosallaDoc = await db.collection("mosalla").doc(mosallaId).get();
  const mosallaName = (mosallaDoc.exists ? mosallaDoc.data().name : null) || "Mosalla";

  const eventTitle = newEventData.title || "New Event";
  const topic = `mosalla_${mosallaId}_events`;

  const payload = {
    notification: {
      title: mosallaName,
      body: `New Event: ${eventTitle}`,
    },
    topic: topic
  };

  try {
    await getMessaging().send(payload);
    console.log(`Successfully sent new event message to topic ${topic} for ${mosallaName}`);
  } catch (error) {
    console.error(`Error sending event message for topic ${topic}:`, error);
  }
});
