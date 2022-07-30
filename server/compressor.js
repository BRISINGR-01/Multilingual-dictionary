const { createGzip,  } = require('node:zlib');
const { pipeline } = require('node:stream');
const {
  createReadStream,
  createWriteStream,
  readFile,
  statSync,
  writeFileSync
} = require('node:fs');
const path = require('path');

const language = "Dutch"

const gzip = createGzip();
const source = createReadStream(path.resolve(__dirname, "databases", language + ".sql"));
const destination = createWriteStream(path.resolve(__dirname, "databases", language + ".sql.zip"));

readFile(path.resolve(__dirname, "compressionData.json"), null, async (err, data) => {
  const sizesData = JSON.parse(data.toString());

  const { size } = statSync(path.resolve(__dirname, "databases", language + ".sql"));

  sizesData[language] = size / 1024;

  writeFileSync(path.resolve(__dirname, "compressionData.json"), JSON.stringify(sizesData));
});


pipeline(source, gzip, destination, (err) => {
  if (err) {
    console.error('An error occurred:', err);
    process.exitCode = 1;
  }
});
