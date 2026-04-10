const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const admin = require("firebase-admin");
const { DateTime } = require("luxon");

admin.initializeApp();

exports.checkPrayerTimes = onSchedule("* * * * *", async (event) => {
  const db = admin.firestore();
  
  // We assume the mosallas operate in a specific timezone, e.g. Asia/Tokyo
  // Adjust if the deployment target differs.
  const now = DateTime.now().setZone("Asia/Tokyo");
  const todayDocId = now.toFormat("dd-MM-yyyy");

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
    
    const prayerDoc = await db.collection("mosalla").doc(mosallaId).collection("prayer_times").doc(todayDocId).get();
    
    if (!prayerDoc.exists) {
      continue;
    }

    const data = prayerDoc.data();
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
          
          const title = `${prayerName} Prayer Time`;
          const body = `It is now time for ${prayerName} at ${mosallaName}.`;

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
  }
});

exports.notifyNewEvent = onDocumentCreated("mosalla/{mosallaId}/events/{eventId}", async (event) => {
  const mosallaId = event.params.mosallaId;
  const newEventData = event.data.data();

  if (!newEventData) return;

  const eventTitle = newEventData.title || "New Event";
  let eventDesc = newEventData.description || "";
  if (eventDesc.length > 50) {
    eventDesc = eventDesc.substring(0, 47) + "...";
  }

  const topic = `mosalla_${mosallaId}_events`;

  const payload = {
    notification: {
      title: `New Event: ${eventTitle}`,
      body: eventDesc,
    },
    topic: topic
  };

  try {
    await getMessaging().send(payload);
    console.log(`Successfully sent new event message to topic ${topic}`);
  } catch (error) {
    console.error(`Error sending event message for topic ${topic}:`, error);
  }
});
