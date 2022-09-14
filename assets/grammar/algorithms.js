function Italian(
  website = "https://www.europassitalian.com/it/risorse-gratuite/grammatica"
) {
  const elements = [
    ...document.getElementsByClassName("entry-content")[0].children,
  ];
  const json = [];
  const tables = {};
  let index2 = 0;
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
        [...elements[5].children].forEach((il) =>
          json.push(`-${il.innerText}`)
        );
        break;
      case "TABLE":
        json.push(`@table:${index2}`);
        tables[index2] = [...el.rows].map((row) =>
          [...row.children].map((col) => col.innerText)
        );
        index2++;
      default:
        break;
    }
  }
}
