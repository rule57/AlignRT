const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {Storage} = require("@google-cloud/storage");
const {createGif} = require("./gif_creator");
const fs = require("fs");

admin.initializeApp();
const storage = new Storage();

exports.createGifFromUserImages = functions
    .runWith({
      memory: "1GB",
      timeoutSeconds: 540})
    .https.onRequest(async (req, res) => {
      const userId = req.query.userId;
      console.log("Received request to create GIF for user: ${userId}");

      try {
        const imagePaths = await getUserImages(userId);
        console.log("Fetched image paths: ${imagePaths}");
        const gifPath = "/tmp/${userId}.gif";
        await createGif(imagePaths, gifPath);
        console.log("Created GIF at path: ${gifPath}");

        // Verify the existence of the GIF file
        if (fs.existsSync(gifPath)) {
          console.log("Verified existence of GIF at path: ${gifPath}");
          await new Promise((resolve) => setTimeout(resolve, 1000));
          await uploadGif(gifPath, userId);
          console.log(`Uploaded GIF to storage`);
          res.status(200).send("GIF created and uploaded successfully");
        } else {
          throw new Error(`GIF file not found at path: ${gifPath}`);
        }
      } catch (error) {
        console.error("Error creating GIF:", error);
        res.status(500).send("Error creating GIF");
      }
    });

/**
 * Fetches user images from Cloud Storage.
 * @param {string} userId - The ID of the user.
 * @return {Promise<string[]>} - Array of image paths.
 */
async function getUserImages(userId) {
  try {
    const [files] = await storage.bucket("align-2f996.appspot.com").getFiles({
      prefix: `users/${userId}/images/`,
    });
    const imagePaths = [];

    for (const file of files) {
      const tempFilePath = `/tmp/${file.name.split("/").pop()}`;
      await file.download({destination: tempFilePath});
      imagePaths.push(tempFilePath);
    }

    console.log(`Downloaded images to temporary paths: ${imagePaths}`);
    return imagePaths;
  } catch (error) {
    console.error("Error fetching user images:", error);
    throw error;
  }
}

/**
 * Uploads GIF to Cloud Storage under the user's specific directory.
 * @param {string} gifPath - The local path to the GIF file.
 * @param {string} userId - The ID of the user.
 * @return {Promise<void>}
 */
async function uploadGif(gifPath, userId) {
  try {
    await storage.bucket("align-2f996.appspot.com").upload(gifPath, {
      destination: `users/${userId}/gif/${userId}.gif`,
    });
    console.log(`Uploaded GIF from ${gifPath} to storage`);
  } catch (error) {
    console.error("Error uploading GIF:", error);
    throw error;
  }
}

/**
 * Cloud Function to create GIFs for all users.
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 */
exports.createGifsForAllUsers = functions
    .runWith({
      memory: "1GB",
      timeoutSeconds: 540})
    .https.onRequest(async (req, res) => {
      const db = admin.firestore();
      const usersRef = db.collection("users");

      try {
        const snapshot = await usersRef.get();
        const promises = [];

        snapshot.forEach((doc) => {
          const userId = doc.id;
          console.log(`Creating GIF for user: ${userId}`);
          const url = `https://us-central1-${process.env.GCLOUD_PROJECT}.cloudfunctions.net/createGifFromUserImages?userId=${userId}`;
          promises.push(fetch(url).then((response) => response.text()));
        });

        await Promise.all(promises);
        res.status(200).send("GIF creation triggered for all users");
      } catch (error) {
        console.error("Error creating GIFs for all users:", error);
        res.status(500).send("Error creating GIFs for all users");
      }
    });
