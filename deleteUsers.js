const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

async function deleteAllUsers(nextPageToken) {
  try {
    const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);
    
    if (listUsersResult.users.length === 0) {
      console.log("No users to delete.");
      return;
    }

    const uids = listUsersResult.users.map(user => user.uid);
    await admin.auth().deleteUsers(uids);
    console.log(`Deleted ${uids.length} users`);

    if (listUsersResult.pageToken) {
      await deleteAllUsers(listUsersResult.pageToken);
    }
  } catch (error) {
    console.error("Error deleting users:", error);
  }
}

// Start deletion process
deleteAllUsers();
