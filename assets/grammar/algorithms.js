function Italian(
  website = "https://www.europassitalian.com/it/risorse-gratuite/grammatica"
) {
  const elements = [
    ...document.getElementsByClassName("entry-content")[0].children,
  ];
  const json = [];
  const tables = {};
  let index2 = +localStorage.index ?? 0;
  for (const el of elements) {
    switch (el.nodeName) {
      case "H2":
      case "H3":
        json.push(`h: ${el.innerText}`);
        break;
      case "P":
        json.push(el.innerText);
        break;
      case "UL":
        json.push("$" + [...el.children].map((il) => il.innerText).join("|"));
        break;
      case "TABLE":
        json.push(`@table:${index2}`);
        tables[index2] = [...el.rows].map((row) =>
          [...row.children].map((col) => col.innerText)
        );
        index2++;
        localStorage.index = index2;
      default:
        break;
    }
  }
  console.log(JSON.stringify(json));
  console.log(JSON.stringify(tables));
}

function Dutch() {
  let columns = 2;

  function parse(str) {
    // let str = e.target.value;
    str = str.split(/[\n\t]/).filter(Boolean);
    console.log(JSON.stringify(str));
    let arr = new Array(str.length / columns)
      .fill()
      .map((_, i) => str.slice(i * columns, i * columns + columns));
    console.log(JSON.stringify(arr));
  }

  parse(`Wij verwachtten ze.	We expected them.
Ze vroeg ze of ze mee wilden komen.	She asked them whether they wanted to come with us.
Ze vroeg aan ze of ze mee wilden komen.	She asked (to) them whether they wanted to come with us.`);
}
