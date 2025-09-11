const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Import JSON data
const careers = require("./careers.json");

async function seedCareers() {
  const batch = db.batch();

  careers.forEach((career) => {
    const docRef = db.collection("careers").doc(); // auto-generated ID
    batch.set(docRef, career);
  });

  await batch.commit();
  console.log("✅ Careers data added successfully!");
}

seedCareers().catch(console.error);
