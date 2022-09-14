// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

void main(List<String> arguments) {
  exitCode = 0; // presume success

  List<String> segments = Platform.script.pathSegments;
  String projectRoot =
      segments.getRange(0, segments.length - 2).join(p.separator);
  Directory grammarFolder =
      Directory((p.join(projectRoot, "assets", "grammar")));

  Iterable<String> languages = grammarFolder
      .listSync()
      .whereType<Directory>()
      .where((dir) => !dir.path.contains("Tables"))
      .map((lang) => p.basename(lang.path));

  bundleGrammar(languages, grammarFolder);
}

Future bundleGrammar(
  Iterable<String> languages,
  Directory grammarFolder,
) async {
  File bundle = File(p.join(grammarFolder.parent.path, "grammarBundle.json"));
  Map<String, dynamic> bundleData = {};

  for (String lang in languages) {
    bundleData[lang] = {};
    Iterable<FileSystemEntity> availableLanguages =
        Directory(p.join(grammarFolder.path, lang))
            .listSync()
            .whereType<Directory>();

    for (var translation in availableLanguages) {
      Map grammar = bundleData[lang][p.basename(translation.path)] = {};
      grammar["tables"] = json.decode(
          File(p.join(translation.path, "tables.json")).readAsStringSync());
      grammar["articles"] = Directory(translation.path)
          .listSync()
          .where((file) => p.basename(file.path) != "tables.json")
          .map((file) => json.decode(File(file.path).readAsStringSync()))
          .toList();
    }
  }

  bundle.writeAsStringSync(json.encode(bundleData));

  return;
}
