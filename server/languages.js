const fr = {
  tags: {
    "French nouns suffixed with -ment": "nouns with -ment",
    "French nouns that have different meanings depending on their gender":
      "nouns with different meanings depending on their gender",
    "French nouns with irregular gender": "irregular gender",
    "French nouns with unattested plurals": "unattested plurals",
    "French verbs taking avoir or être as auxiliary":
      "avoir or être (auxiliary)",
    "French verbs taking être as auxiliary": "être (auxiliary)",
    "French verbs with conjugation -ayer": "-ayer",
    "French verbs with conjugation -cer": "-cer",
    "French verbs with conjugation -e-er": "-e-er",
    "French verbs with conjugation -er": "-er",
    "French verbs with conjugation -eyer": "-eyer",
    "French verbs with conjugation -ger": "-ger",
    "French verbs with conjugation -ir": "-ir",
    "French verbs with conjugation -xxer": "-xxer",
    "French verbs with conjugation -yer": "-yer",
    "French verbs with conjugation -é-er": "-é-er",
    "French verbs with conjugation -ïr": "-ïr",
    "French verbs with conjugation aller": "conjugation aller",
    "French verbs with conjugation bouillir": "conjugation bouillir",
    "French verbs with conjugation haïr": "conjugation haïr",
    "French verbs with conjugation ouïr": "conjugation ouïr",
    "French verbs with conjugation seoir": "conjugation seoir",
    "French verbs with conjugation tenir": "conjugation tenir",
    "French verbs with conjugation venir": "conjugation venir",
    "French verbs with placeholder en": "placeholder en",
    "French verbs with placeholder y": "placeholder y",
    "Quebec French ": "Quebec French ",
    "Canadian French": "Canadian French",
    "Belgian French": "Belgian French",
    "Cajun French": "Cajun French",
    Verlan: "Verlan",
    "Switzerland French ": "Switzerland French ",
    "European French ": "European French ",
    "Acadian French ": "Acadian French ",
    "Ivorian French": "Ivorian French",
    "Provence French": "Provence French",
    "African French": "African French",
    "Congolese French": "Congolese French",
  },
  orderData: (wordObject) => {
    const word = wordObject.word;
    const data = wordObject.head_templates[0].expansion;
    const vowels = ["a", "e", "i", "o", "u", "y"];
    let displayString = word;
    const extractedData = getExtractedData(data);

    switch (wordObject.pos) {
      case "noun":
        let gender = getGender(data);
        const plural = getProp("plural", extractedData);

        if (gender) {
          if (!vowels.some((vowel) => word.startsWith(vowel))) {
            gender = {
              m: "le",
              f: "la",
            }[gender];
          } else if (plural) {
            gender = {
              m: "un",
              f: "une",
            }[gender];
          }

          if (gender) displayString = `${gender} ${word}`;
        }

        if (plural && plural !== word + "s") displayString += `, ${plural}`;

        break;

      case "adj":
        removeProps(["masculine", "feminine", "plural"], extractedData);

      case "adv":
        removeProps(["comparative", "superlative"], extractedData);
        break;
    }

    return getResult(displayString, extractedData);
  },
  formTables: {
    adj: {
      customMethod: (forms, word) => {
        if (forms.length === 1) return [forms[0].tags[0], forms[0].form];

        return [
          ["#", "Sg.", "Pl."],
          [
            "m",
            word,
            forms.find(
              (form) =>
                form.tags.includes("masculine") && form.tags.includes("plural")
            )?.form,
          ],
          [
            "f",
            forms.find(
              (form) => form.tags.length === 1 && form.tags[0] === "feminine"
            )?.form,
            forms.find(
              (form) =>
                form.tags.includes("feminine") && form.tags.includes("plural")
            )?.form,
          ],
        ];
      },
    },
    verb: {
      customMethod: (forms, word) => {
        const standartConjugationTables = {
          indicative: {
            provided: ["present", "imperfect", "future", ["historic", "past"]],
            automatic: [
              "pluperfect",
              "past",
              "perfect",
              ["perfect", "present"],
            ],
          },
          subjunctive: {
            provided: ["present", "imperfect"],
            automatic: ["past", "pluperfect"],
          },
          conditional: {
            provided: ["empty"],
            automatic: ["perfect"], // x2
          },
        };
        const nonStandartTables = [
          ["infinitive"],
          ["infinitive", "multiword-construction"],
          ["gerund", "participle", "present"],
          ["gerund", "multiword-construction", "participle", "present"],
          ["participle", "past"],
        ];
        return forms
          .filter(
            ({ tags }) =>
              tags.includes("first-person") && tags.includes("singular")
          )
          .map(({ tags }) =>
            tags.filter((tag) => tag !== "first-person" && tag !== "singular")
          );
      },
    },
  },
};

const nl = {
  tags: {
    Belgium: "Belgium",
    Flanders: "Flanders",
    vulgar: "vulgar",
    offensive: "offensive",

    "Dutch words interfixed with -s-": "-s-",
    "Dutch words interfixed with -en-": "-en-",
    "Dutch prefixed verbs with ver-": "ver-",
    "Dutch prefixed verbs with be-": "be-",
    "Dutch nouns with lengthened vowel in the plural":
      "nouns with lengthened vowel in the plural",
    "Dutch nouns with f+m gender": "nouns with f+m gender",
    "Dutch words interfixed with -e-": "-e-",
    "Dutch separable verbs with af": "af|",
    "Dutch prefixed verbs with ont-": "ont-",
    "Dutch separable verbs with aan": "aan|",
    "Dutch nouns with Latin plurals": "nouns with Latin plurals",
    "Dutch univerbations": "univerbations",
    "Dutch nouns with common gender": "nouns with common gender",
    "Dutch separable verbs with op": "op|",
    "Dutch words circumfixed with ver- -en": "ver- -en",
    "Dutch separable verbs with uit": "uit|",
    "Dutch heteronyms": "heteronyms",
    "Dutch prepositions": "prepositions",
    "Dutch pronouns": "pronouns",
    "Dutch onomatopoeias": "onomatopoeias",
    "Dutch pluralia tantum": "pluralia tantum",
    "Dutch separable verbs with in": "in|",
    "Dutch prefixed verbs with over-": "over-",
    "Dutch words circumfixed with ont- -en": "ont- -en",
    "Dutch words circumfixed with be- -en": "be- -en",
    "Dutch determiners": "determiners",
    "Dutch proverbs": "proverbs",
    "Dutch weak verbs (-cht)": "weak verbs (-cht)",
    "Dutch verbs with two conjugations": "verbs with two conjugations",
    "Dutch blends": "blends",
    "Dutch separable verbs with door": "door|",
    "Dutch prefixed verbs with onder-": "onder-",
    "Dutch separable verbs with over": "over|",
    "Dutch words interfixed with -n-": "-n-",
    "Dutch separable verbs with om": "om|",
    "Dutch words interfixed with -er-": "-er-",
    "Dutch prefixed verbs with om-": "om-",
    "Dutch personal pronouns": "personal pronouns",
    "Dutch separable verbs with toe": "toe|",
    "Dutch metonyms": "metonyms",
    "Dutch prefixed verbs with door-": "door-",
    "Dutch prefixed verbs with ge-": "ge-",
    "Dutch diminutiva tantum": "diminutiva tantum",
    "Dutch separable verbs with terug": "terug|",
    "Dutch prefixed verbs with her-": "her-",
    "Dutch separable verbs with weg": "weg|",
    "Dutch euphemisms": "euphemisms",
    "Dutch separable verbs with na": "na|",
    "Dutch separable verbs with voor": "voor|",
    "Dutch similes": "similes",
    "Dutch separable verbs with bij": "bij|",
    "Dutch back-formations": "back-formations",
    "Dutch exocentric compounds": "exocentric compounds",
    "Dutch nouns with Greek plurals": "nouns with Greek plurals",
    "Dutch separable verbs with onder": "onder|",
    "Dutch separable verbs with mee": "mee|",
    "Dutch separable verbs with neer": "neer|",
    "Dutch prefixed verbs with vol-": "vol-",
    "Dutch modal particles": "modal particles",
    "Dutch terms of address": "terms of address",
    "Dutch relative pronouns": "relative pronouns",
    "Dutch ethnic slurs": "ethnic slurs",
    "Dutch prefixed verbs with mis-": "mis-",
    "Dutch separable verbs with open": "open|",
    "Dutch separable verbs with samen": "samen|",
    "Dutch words circumfixed with ge- -te": "ge- -te",
    "Dutch circumpositions": "circumpositions",
    "Dutch demonstrative determiners": "demonstrative determiners",
    "Dutch prefixed verbs with aan-": "aan-",
    "Dutch articles": "articles",
    "Dutch possessive determiners": "possessive determiners",
    "Dutch separable verbs with vast": "vast|",
    "Dutch separable verbs with voort": "voort|",
    "Dutch neologisms": "neologisms",
    "Dutch separable verbs with tegen": "tegen|",
    "Dutch separable verbs with vol": "vol|",
    "Dutch bahuvrihi compounds": "bahuvrihi compounds",
    "Dutch indefinite determiners": "indefinite determiners",
    "Dutch intensifiers": "intensifiers",
    "Dutch nouns with glide vowel in plural":
      "nouns with glide vowel in plural",
    "Dutch rebracketings": "rebracketings",
    "Dutch negative polarity items": "negative polarity items",
    "Dutch prefixed verbs with voor-": "voor-",
    "Dutch reduplications": "reduplications",
    "Dutch separable verbs with los": "los|",
    "Dutch words circumfixed with be- -igen": "be- -igen",
    "Dutch interrogative pronouns": "interrogative pronouns",
    "Dutch separable verbs with binnen": "binnen|",
    "Dutch indefinite pronouns": "indefinite pronouns",
    "Dutch prefixed verbs with weer-": "weer-",
    "Dutch separable verbs with achter": "achter|",
    "Dutch separable verbs with dood": "dood|",
    "Dutch demonstrative pronouns": "demonstrative pronouns",
    "Dutch eye dialect": "eye dialect",
    "Dutch prefixed verbs with achter-": "achter-",
    "Dutch separable verbs with klaar": "klaar|",
    "Dutch separable verbs with mis": "mis|",
    "Dutch separable verbs with rond": "rond|",
    "Dutch circumfixes": "circumfixes",
    "Dutch exocentric verb-noun compounds": "exocentric verb-noun compounds",
    "Dutch separable verbs with dicht": "dicht|",
    "Dutch separable verbs with overeen": "overeen|",
    "Dutch separable verbs with vrij": "vrij|",
    "Dutch words circumfixed with be- -d": "be- -d",
    "Dutch endocentric verb-noun compounds": "endocentric verb-noun compounds",
    "Dutch genericized trademarks": "genericized trademarks",
    "Dutch interfixes": "interfixes",
    "Dutch reflexive pronouns": "reflexive pronouns",
    "Dutch separable verbs with vooruit": "vooruit|",
    "Dutch deverbals": "deverbals",
    "Dutch interrogative determiners": "interrogative determiners",
    "Dutch prefixed verbs with er-": "er-",
    "Dutch separable verbs with gelijk": "gelijk|",
    "Dutch separable verbs with schoon": "schoon|",
    "Dutch separable verbs with stil": "stil|",
    "Dutch separable verbs with terecht": "terecht|",
    "Dutch separable verbs with ver": "ver|",
    "Dutch separable verbs with zwart": "zwart|",
    "Dutch words interfixed with -es-": "-es-",
    "Dutch hypercorrections": "hypercorrections",
    "Dutch nouns with English plurals": "nouns with English plurals",
    "Dutch prefixed verbs with wan-": "wan-",
    "Dutch separable verbs with aaneen": "aaneen|",
    "Dutch separable verbs with bijeen": "bijeen|",
    "Dutch separable verbs with groot": "groot|",
    "Dutch separable verbs with kwijt": "kwijt|",
    "Dutch separable verbs with leeg": "leeg|",
    "Dutch separable verbs with thuis": "thuis|",
    "Dutch separable verbs with verder": "verder|",
    "Dutch separable verbs with voorbij": "voorbij|",
    "Dutch verb-forming circumfixes": "verb-forming circumfixes",
    "Dutch expressions": "expressions",
    "Dutch homophonic translations": "homophonic translations",
    "Dutch internationalisms": "internationalisms",
    "Dutch particles": "particles",
    "Dutch prefixed verbs with herbe-": "herbe-",
    "Dutch prefixed verbs with weder-": "weder-",
    "Dutch pseudo-loans from English": "pseudo-loans from English",
    "Dutch relative determiners": "relative determiners",
    "Dutch separable verbs with achterom": "achterom|",
    "Dutch separable verbs with beet": "beet|",
    "Dutch separable verbs with bloot": "bloot|",
    "Dutch separable verbs with bot": "bot|",
    "Dutch separable verbs with dwars": "dwars|",
    "Dutch separable verbs with gevangen": "gevangen|",
    "Dutch separable verbs with goed": "goed|",
    "Dutch separable verbs with kapot": "kapot|",
    "Dutch separable verbs with lastig": "lastig|",
    "Dutch separable verbs with mede": "mede|",
    "Dutch separable verbs with prijs": "prijs|",
    "Dutch separable verbs with recht": "recht|",
    "Dutch separable verbs with tussen": "tussen|",
    "Dutch separable verbs with uiteen": "uiteen|",
    "Dutch separable verbs with waar": "waar|",
    "Dutch separable verbs with wild": "wild|",
    "Dutch words circumfixed with ver- -te": "ver- -te",
    "Dutch dysphemisms": "dysphemisms",
    "Dutch hyperboles": "hyperboles",
    "Dutch noun-forming circumfixes": "noun-forming circumfixes",
    "Dutch postpositions": "postpositions",
    "Dutch prefixed verbs with landver-": "landver-",
    "Dutch prefixed verbs with machtsver-": "machtsver-",
    "Dutch prefixed verbs with wortel-": "wortel-",
    "Dutch retronyms": "retronyms",
    "Dutch separable verbs with achterop": "achterop|",
    "Dutch separable verbs with achteruit": "achteruit|",
    "Dutch separable verbs with adem": "adem|",
    "Dutch separable verbs with asem": "asem|",
    "Dutch separable verbs with bekend": "bekend|",
    "Dutch separable verbs with belang": "belang|",
    "Dutch separable verbs with bewust": "bewust|",
    "Dutch separable verbs with bezig": "bezig|",
    "Dutch separable verbs with boek": "boek|",
    "Dutch separable verbs with boven": "boven|",
    "Dutch separable verbs with brand": "brand|",
    "Dutch separable verbs with buik": "buik|",
    "Dutch separable verbs with buit": "buit|",
    "Dutch separable verbs with buiten": "buiten|",
    "Dutch separable verbs with daar": "daar|",
    "Dutch separable verbs with deel": "deel|",
    "Dutch separable verbs with diep": "diep|",
    "Dutch separable verbs with down": "down|",
    "Dutch separable verbs with droog": "droog|",
    "Dutch separable verbs with eruit": "eruit|",
    "Dutch separable verbs with flauw": "flauw|",
    "Dutch separable verbs with gade": "gade|",
    "Dutch separable verbs with gebruik": "gebruik|",
    "Dutch separable verbs with gerust": "gerust|",
    "Dutch separable verbs with gewaar": "gewaar|",
    "Dutch separable verbs with grijs": "grijs|",
    "Dutch separable verbs with hard": "hard|",
    "Dutch separable verbs with heen": "heen|",
    "Dutch separable verbs with herop": "herop|",
    "Dutch separable verbs with huis": "huis|",
    "Dutch separable verbs with kennis": "kennis|",
    "Dutch separable verbs with klok": "klok|",
    "Dutch separable verbs with kort": "kort|",
    "Dutch separable verbs with kwaad": "kwaad|",
    "Dutch separable verbs with langs": "langs|",
    "Dutch separable verbs with les": "les|",
    "Dutch separable verbs with lief": "lief|",
    "Dutch separable verbs with lip": "lip|",
    "Dutch separable verbs with mouw": "mouw|",
    "Dutch separable verbs with neder": "neder|",
    "Dutch separable verbs with omhoog": "omhoog|",
    "Dutch separable verbs with omver": "omver|",
    "Dutch separable verbs with onderuit": "onderuit|",
    "Dutch separable verbs with opeen": "opeen|",
    "Dutch separable verbs with opzien": "opzien|",
    "Dutch separable verbs with plaats": "plaats|",
    "Dutch separable verbs with plat": "plat|",
    "Dutch separable verbs with scheef": "scheef|",
    "Dutch separable verbs with scherp": "scherp|",
    "Dutch separable verbs with schuil": "schuil|",
    "Dutch separable verbs with stop": "stop|",
    "Dutch separable verbs with stuk": "stuk|",
    "Dutch separable verbs with tanden": "tanden|",
    "Dutch separable verbs with tegemoet": "tegemoet|",
    "Dutch separable verbs with teleur": "teleur|",
    "Dutch separable verbs with teloor": "teloor|",
    "Dutch separable verbs with tentoon": "tentoon|",
    "Dutch separable verbs with teweeg": "teweeg|",
    "Dutch separable verbs with up": "up|",
    "Dutch separable verbs with vals": "vals|",
    "Dutch separable verbs with vet": "vet|",
    "Dutch separable verbs with vooraf": "vooraf|",
    "Dutch separable verbs with vreemd": "vreemd|",
    "Dutch separable verbs with weer": "weer|",
    "Dutch separable verbs with wel": "wel|",
    "Dutch separable verbs with wit": "wit|",
    "Dutch separable verbs with zeker": "zeker|",
    "Dutch words interfixed with -i-": "-i-",
    "Dutch words interfixed with -o-": "-o-",
  },
  orderData: (wordObject) => {
    const word = wordObject.word;
    const data = wordObject.head_templates[0].expansion;
    let displayString = word;
    const extractedData = getExtractedData(data);

    switch (wordObject.pos) {
      case "noun":
        let gender = getGender(data);
        const plural = getProp("plural", extractedData);
        const diminutive = getProp("diminutive", extractedData);

        gender = {
          m: "de",
          f: "de",
          n: "het",
        }[gender];

        if (gender) displayString = `${gender} ${word}`;

        if (plural) {
          if (plural && plural !== word + "en") displayString += `, ${plural}`;
        }
        if (diminutive && diminutive.replace(" n", "") !== word + "je")
          displayString += `; diminutive: ${diminutive}`;

      case "adj":
      case "adv":
        removeProps(["comparative", "superlative"], extractedData);
    }

    return getResult(displayString, extractedData);
  },
};

module.exports = { fr, nl };

function getGender(data) {
  const match =
    data.match(/\s(m|f|n) or (m|f|n)\s/) || data.match(/\s(m|f|n)\s/);

  return match ? match[0].trim() : null;
}

function getProp(prop, data) {
  const propIndex = data.findIndex((d) => d.includes(prop + " "));

  if (propIndex === -1) return null;

  return data.splice(propIndex, 1)[0].replace(prop + " ", "");
}

function removeProps(props, data) {
  props.forEach((prop) => {
    const index = data.findIndex((d) => d.includes(prop + " "));

    if (index !== -1) data.splice(index, 1);
  });
}

function getResult(displayString, data) {
  return data.length ? `${displayString} (${data.join(", ")})` : displayString;
}

function getExtractedData(data) {
  const inBracketsMatch = data.match(/\((.+?)\)/);

  if (!inBracketsMatch) return [];

  return inBracketsMatch[1].split(", ");
}