const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin SDK
const serviceAccount = require('./path-to-your-service-account-key.json'); // Replace with your service account key

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  // Add your Firebase project configuration here
});

const db = admin.firestore();

async function seedResources() {
  try {
    console.log('Starting to seed resources...');
    
    // Read the resources JSON file
    const resourcesPath = path.join(__dirname, 'resources.json');
    const resourcesData = JSON.parse(fs.readFileSync(resourcesPath, 'utf8'));
    
    console.log(`Found ${resourcesData.length} resources to seed`);
    
    // Clear existing resources (optional - remove this if you want to keep existing data)
    const existingResources = await db.collection('resources').get();
    if (!existingResources.empty) {
      console.log('Clearing existing resources...');
      const batch = db.batch();
      existingResources.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      await batch.commit();
    }
    
    // Add resources to Firestore
    const batch = db.batch();
    const resourcesRef = db.collection('resources');
    
    resourcesData.forEach((resource, index) => {
      const docRef = resourcesRef.doc();
      
      // Convert publishDate string to Firestore Timestamp
      const publishDate = admin.firestore.Timestamp.fromDate(new Date(resource.publishDate));
      
      batch.set(docRef, {
        ...resource,
        publishDate: publishDate,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
    
    await batch.commit();
    console.log('Successfully seeded resources to Firestore!');
    
  } catch (error) {
    console.error('Error seeding resources:', error);
  } finally {
    process.exit(0);
  }
}

// Run the seeder
seedResources();
