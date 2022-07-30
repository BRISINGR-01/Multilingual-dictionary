const transformer = require("./transformer");
const fs = require("fs");
const commands = require("./dbCommands");
const path = require("path");

module.exports = download;
async function download(stream, lang) {
  let lastLine = "",
    index = 0;

  const db = await commands.init(lang);

  return new Promise((resolve) => {
    stream.on("data", (chunk) => {
      chunk = chunk.toString();

      let lines = (lastLine + chunk).split("\n");

      lastLine = lines.pop();

      const words = transformer(lines.map(JSON.parse));

      for (const i in words) {
        db.run(
          commands.add(words[i], lang, index),
          (err) => err && console.log(err)
        );

        index++;
      }
    });

    stream.on("end", () => {
      db.close();

      resolve();
    });
  });
}

// download(
//   fs.createReadStream(
//     path.resolve("./app/databases/kaikki.org-dictionary-" + "Dutch" + ".txt")
//   ),
//   "Dutch"
// );
