const {createCanvas, loadImage} = require("canvas");
const GIFEncoder = require("gifencoder");
const fs = require("fs");

exports.createGif = async function(imagePaths, gifPath) {
  if (imagePaths.length === 0) {
    throw new Error("No images provided to create a GIF");
  }

  const images = await Promise.all(imagePaths.map((path) => loadImage(path)));
  const width = images[0].width;
  const height = images[0].height;

  const encoder = new GIFEncoder(width, height);
  encoder.createReadStream().pipe(fs.createWriteStream(gifPath));

  encoder.start();
  encoder.setRepeat(0); // 0 for repeat, -1 for no-repeat
  encoder.setDelay(500); // frame delay in ms
  encoder.setQuality(10); // image quality. 10 is default.

  const canvas = createCanvas(width, height);
  const ctx = canvas.getContext("2d");

  images.forEach((image) => {
    ctx.drawImage(image, 0, 0, width, height);
    encoder.addFrame(ctx);
  });

  encoder.finish();
};
