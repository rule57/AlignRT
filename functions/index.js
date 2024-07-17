const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {Storage} = require("@google-cloud/storage");
const {createGif} = require("./gif_creator");

admin.initializeApp();
const storage = new Storage();

/**
 * Cloud Function to create a GIF from user images and upload it to storage.
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 */
exports.createGifFromUserImages = functions
    .runWith({memory: "1GB", timeoutSeconds: 540})
    .https.onRequest(async (req, res) => {
      const userId = req.query.userId;

      try {
        const imagePaths = await getUserImages(userId);
        const gifPath = `/tmp/${userId}.gif`;
        await createGif(imagePaths, gifPath);
        await uploadGif(gifPath);
        res.status(200).send("GIF created and uploaded successfully");
      } catch (error) {
        console.error("Error creating GIF: ", error);
        res.status(500).send("Error creating GIF");
      }
    });

/**
 * Fetches user images from Cloud Storage.
 * @param {string} userId - The ID of the user.
 * @return {Promise<string[]>} - Array of image paths.
 */
async function getUserImages(userId) {
  const [files] = await storage.bucket("align-2f996.appspot.com").getFiles({
    prefix: `users/${userId}/images/`,
  });
  const imagePaths = [];

  for (const file of files) {
    const tempFilePath = `/tmp/${file.name.split("/").pop()}`;
    await file.download({destination: tempFilePath});
    imagePaths.push(tempFilePath);
  }

  return imagePaths;
}
/**
 * Uploads GIF to Cloud Storage.
 * @param {string} gifPath - The local path to the GIF file.
 * @return {Promise<void>}
 */
async function uploadGif(gifPath) {
  await storage.bucket("align-2f996.appspot.com").upload(gifPath, {
    destination: `posts/${gifPath.split("/").pop()}`,
  });
}
