import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:multilingual_dictionary/sharedutilities.dart'
    show ListOfWordObjects, getNestedVal, getCategories;
import 'package:multilingual_dictionary/languageParsers/fr.dart' as fr;

String getUrlForRawJSON(String lang) =>
    'https://kaikki.org/dictionary/$lang/all-senses/kaikki.org-dictionary-$lang-all-senses.json';
// https://kaikki.org/dictionary/English/all-non-inflected-senses/kaikki.org-dictionary-English-all-n-laGJUY

Future<ListOfWordObjects> fetchData(String lang) async {
  // var result = await http.get(Uri.parse(
  //     "https://kaikki.org/dictionary/French/most-senses-10/kaikki.org-dictionary-French-most-senses-10.j-esPREQ"
  //     // "https://kaikki.org/dictionary/Latin/by-pos/particle/kaikki.org-dictionary-Latin-by-pos-particle.-2XVa7."));
  //     ));

  // return result.body
  //     .split(RegExp(r"\n"))
  //     .where((str) => str.isNotEmpty)
  //     .map((obj) => json.decode(obj) as Map<String, dynamic>)
  //     .toList();

  return jsonData;
  // return [jsonData[0]];
}

ListOfWordObjects generalParse(ListOfWordObjects data) {
  ListOfWordObjects parsedData = [];

  for (var wordEntry in data) {
    parsedData.add({
      "pos": wordEntry["pos"], // part of speech
      "forms": wordEntry["forms"],
      "word": wordEntry["word"],
      "origin": wordEntry["etymology_text"],
      "temporaryData": {
        "other": wordEntry["head_templates"],
        "categories": wordEntry["senses"].map((sense) => {
              "tags": sense["tags"],
              "categories": sense["categories"],
            })
      },
      "lang": wordEntry["lang_code"],
      "ipas": wordEntry["sounds"]
          ?.where((soundObject) => (soundObject as Map).containsKey("ipa")),
      "translations": wordEntry["senses"].map((sense) => {
            "value": sense["glosses"],
            "examples": sense["examples"],
          }),
      "metadata": {}
    });
  }

  return parsedData;
}

ListOfWordObjects languageParse(ListOfWordObjects words) {
  for (var word in words) {
    Map? metadataPath = fr.types[word['pos']];
    if (metadataPath != null) {
      for (var prop in metadataPath.keys) {
        word['metadata'][prop] = getNestedVal(word, metadataPath[prop]);
      }
    }

    word['categories'] =
        getCategories(word['temporaryData']['categories'], fr.categoriesList);
// categories not working
    word.remove('temporaryData');
  }

  return words;
}

void check(ListOfWordObjects data) {
  for (var word in data) {
    if (word["metadata"].isNotEmpty) print(word["categories"]);
  }
}

void download(String lang) async {
  ListOfWordObjects data = await fetchData(lang);
  ListOfWordObjects parsedData = generalParse(data);
  // ListOfWordObjects finalData = languages[lang](data);
  ListOfWordObjects finalData = languageParse(parsedData);
  check(finalData);
  // print(parsedData);
  print("done");
}

// Map languages = {"French": fr};
ListOfWordObjects jsonData = [{}];
