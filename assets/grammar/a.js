let columns = 2;

function parse(str) {
  // let str = e.target.value;
  str = str.split(/[\n\t]/).filter(Boolean);
  console.log(JSON.stringify(str))
  let arr = new Array(str.length / columns)
    .fill()
    .map((_, i) => str.slice(i * columns, i * columns + columns));
  console.log(JSON.stringify(arr));
}

parse(`Wij verwachtten ze.	We expected them.
Ze vroeg ze of ze mee wilden komen.	She asked them whether they wanted to come with us.
Ze vroeg aan ze of ze mee wilden komen.	She asked (to) them whether they wanted to come with us.`);
