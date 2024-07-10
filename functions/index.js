/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {Storage} = require("@google-cloud/storage");
const {createGif} = require("./gif_creator"); // Import the GIF creator module

admin.initializeApp();
const storage = new Storage();

exports.createGifFromUserImages = functions.https.onRequest(async (req, res) => {
  const userId = req.query.userId; // Assuming userId is passed as a query parameter

  try {
    const imagePaths = await getUserImages(userId);
    const gifPath = `/tmp/${userId}.gif`;
    await createGif(imagePaths, gifPath);
    await uploadGif(gifPath);
    res.status(200).send("GIF created and uploaded successfully");
  } catch (error) {
    console.error("Error creating GIF:", error);
    res.status(500).send("Error creating GIF");
  }
});

async function getUserImages(userId) {
  const [files] = await storage.bucket("your-user-bucket-name").getFiles({prefix: `${userId}/images/`});
  const imagePaths = [];

  for (const file of files) {
    const tempFilePath = `/tmp/${file.name.split("/").pop()}`;
    await file.download({destination: tempFilePath});
    imagePaths.push(tempFilePath);
  }

  return imagePaths;
}

async function uploadGif(gifPath) {
  await storage.bucket("your-post-bucket-name").upload(gifPath, {
    destination: `gifs/${gifPath.split("/").pop()}`,
  });
}
