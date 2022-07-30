const http = require("http");


http.get("http://localhost:3000/Dutch", res => {
  console.log(res)
  res.on("readable", console.log);
  res.on("pause", console.log);
  res.on("end", console.log);
  res.on("data", chunk => console.log(chunk))
  res.on("error", chunk => console.log(chunk))
})