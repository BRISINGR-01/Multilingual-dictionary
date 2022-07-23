import 'package:multilingual_dictionary/sharedutilities.dart'
    show ListOfWordObjects, getNestedVal, getCategories;

ListOfWordObjects fr(ListOfWordObjects data) {
  for (var word in data) {
    Map? metadataPath = types[word['pos']];
    if (metadataPath != null) {
      for (var prop in metadataPath.keys) {
        word['metadata'][prop] = getNestedVal(word, metadataPath[prop]);
      }
    }

    word['categories'] =
        getCategories(word['temporaryData']['categories'], categoriesList);

    word.remove('temporaryData');
  }

  return data;
}

Map types = {
  'noun': {
    'gender': ['temporaryData', 'other', 0, 'args', '1']
  },
};

Set<String> categoriesList = {
  "French verbs with conjugation -ayer",
  "French verbs with conjugation -cer",
  "French verbs with conjugation -e-er",
  "French verbs with conjugation -er",
  "French verbs with conjugation -eyer",
  "French verbs with conjugation -ger",
  "French verbs with conjugation -ir",
  "French verbs with conjugation -xxer",
  "French verbs with conjugation -yer",
  "French verbs with conjugation -é-er",
  "French verbs with conjugation -ïr",
  "French verbs with conjugation aller",
  "French verbs with conjugation bouillir",
  "French verbs with conjugation haïr",
  "French verbs with conjugation ouïr",
  "French verbs with conjugation seoir",
  "French verbs with conjugation tenir",
  "French verbs with conjugation venir",
  "French verbs taking \u00eatre as auxiliary",
  "French verbs taking avoir or \u00eatre as auxiliary",
  "Lemmas",
  "masculine"
};
