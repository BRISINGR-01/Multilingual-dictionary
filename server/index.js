const fs = require("fs");
const path = require("path");
const zlib = require("node:zlib");
const { pipeline } = require("node:stream");
const http = require("http");
// const https = require("https");
const languages = require("./languages.json");

const https = {
  get: (_, cb) =>
    cb(
      fs.createReadStream(
        __dirname +
          "/../app/databases/kaikki.org-dictionary-" +
          "Dutch" +
          ".txt"
      )
    ),
}; // testing

const server = http.createServer((req, res) => {
  const request = decodeURI(req.url.replace("/", ""));

  console.log(request);
  if (languages.includes(request)) {
    let file_path = fs.existsSync(
      path.resolve(__dirname, "databases", request + ".sql.zip")
    )
      ? path.resolve(__dirname, "databases", request + ".sql.zip")
      : path.resolve(__dirname, "databases", "Dutch.sql.zip");

    readStream = fs.createReadStream(file_path);

    fs.stat(file_path, (error, stat) => {

      res.writeHead(200, {
        "Content-Encoding": "gzip",
        "Content-Length": stat.size,
        "original-Length": 11804,
      });

      readStream.pipe(res);
    });

    // const url = `https://kaikki.org/dictionary/${request}/words/kaikki.org-dictionary-${request.replace(
    //   /\s/g,
    //   ""
    // )}.json`;
    // https.get(url, async (stream) => {
    //   await downloadLanguage(stream, request, res);

    // });

    return;
  }

  res.end();
});

server.listen(3000, console.log);
