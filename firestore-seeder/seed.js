const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Firebase init
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const data = require("./quizzes.json");

async function seedData() {
  const quizzes = data.quizzes;

  for (const [tier, tierData] of Object.entries(quizzes)) {
    console.log(`\n🚀 Seeding tier: ${tier}`);

    const questions = tierData.questions;

    for (const [qid, qdata] of Object.entries(questions)) {
      await db
        .collection("quizzes")
        .doc(tier)
        .collection("questions")
        .doc(qid)
        .set({
          question: qdata.question,
          options: qdata.options,
        });

      console.log(`✅ Added ${tier} -> ${qid}`);
    }
  }
}

seedData()
  .then(() => console.log("\n🔥 Seeding complete"))
  .catch((err) => console.error("❌ Error seeding data:", err));
