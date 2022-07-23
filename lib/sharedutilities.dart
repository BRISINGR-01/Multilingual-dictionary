typedef ListOfWordObjects = List<Map<String, dynamic>>;

dynamic getNestedVal(tree, List path) {
  var val = tree;

  for (var prop in path) {
    val = val[prop];
  }

  return val;
}

Set<String> getCategories(Iterable rawCategories, Set<String> selected) {
  Set<String> categories = {};

  rawCategories.forEach((tr) {
    tr['categories']?.forEach((categoryObject) {
      if (selected.contains(categoryObject["name"])) {
        categories.add(categoryObject["name"]);
      }
      categoryObject['parents'].forEach((parent) {
        if (selected.contains(parent)) {
          categories.add(parent);
        }
      });
    });

    tr["tags"]?.forEach((tag) {
      // print([tag, selectedCategories.contains(tag)]);
      if (selected.contains(tag)) {
        categories.add(tag);
      }
    });
  });

  return categories;
}

Set<String> defaultCategories = {
  "auxiliary",
  "archaic",
  "alternative",
  "transitive",
  "intransitive",
  "reflexive"
};
