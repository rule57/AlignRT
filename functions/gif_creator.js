const {createCanvas, loadImage} = require("canvas");
const GIFEncoder = require("gifencoder");
const fs = require("fs");

/**
 * Creates a GIF from an array of image paths.
 * @param {string[]} imagePaths - Array of paths to images.
 * @param {string} outputPath - Path to save the created GIF.
 * @return {Promise<void>}
 */
async function createGif(imagePaths, outputPath) {
  if (imagePaths.length === 0) {
    throw new Error("No images provided to create a GIF");
  }

  console.log("Starting GIF creation process");

  // Load all images
  const images = await Promise.all(imagePaths.map((path) => loadImage(path)));
  console.log("Loaded images");

  // Create a canvas with the dimensions of the first image
  const oWidth = images[0].width;
  const oHeight = images[0].height;
  const encoder = new GIFEncoder(oHeight, oWidth);

  // Stream the encoder output to a file
  const stream = fs.createWriteStream(outputPath);
  encoder.createReadStream().pipe(stream);

  encoder.start();
  encoder.setRepeat(0); // 0 for repeat, -1 for no-repeat
  encoder.setDelay(300); // frame delay in ms
  encoder.setQuality(10); // image quality. 10 is default.

  const canvas = createCanvas(oHeight, oWidth); // Sw
  const ctx = canvas.getContext("2d");

  // Draw each image onto the canvas and add it to the GIF, rotated
  for (let i = 0; i < images.length; i++) {
    ctx.clearRect(0, 0, oHeight, oWidth);
    ctx.save();
    ctx.translate(oHeight / 2, oWidth / 2);
    ctx.rotate(Math.PI / 2);
    ctx.drawImage(images[i], -oWidth / 2, -oHeight / 2, oWidth, oHeight);
    ctx.restore();
    encoder.addFrame(ctx);
    console.log("Added frame ${i + 1}");
  }

  encoder.finish();
  console.log("Finished GIF creation");

  return new Promise((resolve, reject) => {
    stream.on("finish", () => {
      console.log("GIF file has been written.");
      resolve();
    });
    stream.on("error", (error) => {
      console.error("Error writing GIF file:", error);
      reject(error);
    });
  });
}

module.exports = {createGif};
