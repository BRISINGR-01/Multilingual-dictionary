// ignore_for_file: file_names

import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:multilingual_dictionary/serach/search.dart';
import 'package:multilingual_dictionary/shared/Loader.dart';

late List<CameraDescription> _cameras;

initCameras() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();

  return _cameras;
}

class CameraInitializer extends StatelessWidget {
  const CameraInitializer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: initCameras(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Loader();
          }

          return const Camera();
        },
      ),
    );
  }
}

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  bool isCameraDenied = false;
  bool hasError = false;
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            isCameraDenied = true;
            break;
          default:
            hasError = true;
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            height: 70,
            width: 70,
            child: FittedBox(
              child: FloatingActionButton(
                onPressed: () async {
                  try {
                    final image = await controller.takePicture();
                    if (mounted) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DisplayPictureScreen(
                            imagePath: image.path,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    // ignore: avoid_print
                    print(e);
                  }
                },
                child: const Icon(
                  Icons.camera,
                  size: 50,
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Center(
          child: isCameraDenied
              ? const Text("Please allow the app to use camera")
              : hasError
                  ? const Text("An error occured")
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: CameraPreview(controller),
                        );
                      },
                    ),
        ));
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  String recText = "";
  List<List<Point<int>>> coordinates = [];
  List<Map<String, dynamic>> data = [];
  double scale = 5;
  init() async {
    final InputImage inputImage = InputImage.fromFilePath(widget.imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    String text = recognizedText.text;
    setState(() {
      recText = text;
    });
    for (TextBlock block in recognizedText.blocks) {
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;
      data.add({
        "text": text,
        "coordinates": cornerPoints,
        "lang": languages.isEmpty
            ? null
            : {
                "aa": "Afar",
                "ab": "Abkhazian",
                "ae": "Avestan",
                "af": "Afrikaans",
                "ak": "Akan",
                "am": "Amharic",
                "an": "Aragonese",
                "ar": "Arabic",
                "as": "Assamese",
                "av": "Avaric",
                "ay": "Aymara",
                "az": "Azerbaijani",
                "ba": "Bashkir",
                "be": "Belarusian",
                "bg": "Bulgarian",
                "bh": "Bihari languages",
                "bi": "Bislama",
                "bm": "Bambara",
                "bn": "Bengali",
                "bo": "Tibetan",
                "br": "Breton",
                "bs": "Bosnian",
                "ca": "Catalan",
                "ce": "Chechen",
                "ch": "Chamorro",
                "co": "Corsican",
                "cr": "Cree",
                "cs": "Czech",
                "cu": "Church Slavic",
                "cv": "Chuvash",
                "cy": "Welsh",
                "da": "Danish",
                "de": "German",
                "dv": "Maldivian",
                "dz": "Dzongkha",
                "ee": "Ewe",
                "el": "Greek",
                "eo": "Esperanto",
                "es": "Spanish",
                "et": "Estonian",
                "eu": "Basque",
                "fa": "Persian",
                "ff": "Fulah",
                "fi": "Finnish",
                "fj": "Fijian",
                "fo": "Faroese",
                "fr": "French",
                "fy": "Western Frisian",
                "ga": "Irish",
                "gd": "Gaelic",
                "gl": "Galician",
                "gn": "Guarani",
                "gu": "Gujarati",
                "gv": "Manx",
                "ha": "Hausa",
                "he": "Hebrew",
                "hi": "Hindi",
                "ho": "Hiri Motu",
                "hr": "Croatian",
                "ht": "Haitian",
                "hu": "Hungarian",
                "hy": "Armenian",
                "hz": "Herero",
                "ia": "Interlingua",
                "id": "Indonesian",
                "ie": "Interlingue",
                "ig": "Igbo",
                "ii": "Sichuan Yi",
                "ik": "Inupiaq",
                "io": "Ido",
                "is": "Icelandic",
                "it": "Italian",
                "iu": "Inuktitut",
                "ja": "Japanese",
                "jv": "Javanese",
                "ka": "Georgian",
                "kg": "Kongo",
                "ki": "Kikuyu",
                "kj": "Kuanyama",
                "kk": "Kazakh",
                "kl": "Kalaallisut",
                "km": "Central Khmer",
                "kn": "Kannada",
                "ko": "Korean",
                "kr": "Kanuri",
                "ks": "Kashmiri",
                "ku": "Kurdish",
                "kv": "Komi",
                "kw": "Cornish",
                "ky": "Kirghiz",
                "la": "Latin",
                "lb": "Luxembourgish",
                "lg": "Ganda",
                "li": "Limburgan",
                "ln": "Lingala",
                "lo": "Lao",
                "lt": "Lithuanian",
                "lu": "Luba-Katanga",
                "lv": "Latvian",
                "mg": "Malagasy",
                "mh": "Marshallese",
                "mi": "Maori",
                "mk": "Macedonian",
                "ml": "Malayalam",
                "mn": "Mongolian",
                "mr": "Marathi",
                "ms": "Malay",
                "mt": "Maltese",
                "my": "Burmese",
                "na": "Nauru",
                "nb": "Norwegian",
                "nd": "North Ndebele",
                "ne": "Nepali",
                "ng": "Ndonga",
                "nl": "Dutch",
                "nn": "Norwegian",
                "no": "Norwegian",
                "nr": "South Ndebele",
                "nv": "Navajo",
                "ny": "Chichewa",
                "oc": "Occitan",
                "oj": "Ojibwa",
                "om": "Oromo",
                "or": "Oriya",
                "os": "Ossetic",
                "pa": "Panjabi",
                "pi": "Pali",
                "pl": "Polish",
                "ps": "Pushto",
                "pt": "Portuguese",
                "qu": "Quechua",
                "rm": "Romansh",
                "rn": "Rundi",
                "ro": "Romanian",
                "ru": "Russian",
                "rw": "Kinyarwanda",
                "sa": "Sanskrit",
                "sc": "Sardinian",
                "sd": "Sindhi",
                "se": "Northern Sami",
                "sg": "Sango",
                "si": "Sinhala",
                "sk": "Slovak",
                "sl": "Slovenian",
                "sm": "Samoan",
                "sn": "Shona",
                "so": "Somali",
                "sq": "Albanian",
                "sr": "Serbian",
                "ss": "Swati",
                "st": "Sotho, Southern",
                "su": "Sundanese",
                "sv": "Swedish",
                "sw": "Swahili",
                "ta": "Tamil",
                "te": "Telugu",
                "tg": "Tajik",
                "th": "Thai",
                "ti": "Tigrinya",
                "tk": "Turkmen",
                "tl": "Tagalog",
                "tn": "Tswana",
                "to": "Tonga",
                "tr": "Turkish",
                "ts": "Tsonga",
                "tt": "Tatar",
                "tw": "Twi",
                "ty": "Tahitian",
                "ug": "Uighur",
                "uk": "Ukrainian",
                "ur": "Urdu",
                "uz": "Uzbek",
                "ve": "Venda",
                "vi": "Vietnamese",
                "vo": "Volapük",
                "wa": "Walloon",
                "wo": "Wolof",
                "xh": "Xhosa",
                "yi": "Yiddish",
                "yo": "Yoruba",
                "za": "Zhuang",
                "zh": "Chinese",
                "zu": "Zulu"
              }[languages.first] // English is purposefully not there
      });
    }
    textRecognizer.close();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    int scale = 6;
    double padding = 2;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const FittedBox(
              fit: BoxFit.scaleDown, child: Text("Select word")),
        ),
        body: Container(
          color: Theme.of(context).colorScheme.tertiary,
          child: InteractiveViewer(
            child: Center(
              child: Stack(
                children: [
                  Image.file(File(widget.imagePath)),
                  for (Map d in data)
                    Stack(
                      children: [
                        Positioned(
                          left: d['coordinates'].first.x.toDouble() / scale -
                              padding,
                          top: d['coordinates'].first.y.toDouble() / scale -
                              padding,
                          child: SizedBox(
                              width: (d["coordinates"][1].x -
                                              d["coordinates"][0].x)
                                          .toDouble() /
                                      scale +
                                  padding * 2,
                              height: (d["coordinates"][3].y -
                                              d["coordinates"][0].y)
                                          .toDouble() /
                                      scale +
                                  padding * 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  // color: const Color.fromARGB(199, 255, 255, 255),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      for (String line in d["text"].split("\n"))
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            for (String word in line.split(" "))
                                              GestureDetector(
                                                onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Search(
                                                        language: d["lang"],
                                                        querry:
                                                            word.toLowerCase(),
                                                      ),
                                                    )),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color:
                                                          const Color.fromARGB(
                                                              199,
                                                              255,
                                                              255,
                                                              255),
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                          padding),
                                                      child: Text(word),
                                                    )),
                                              )

                                            // SizedBox(
                                            //   child: ElevatedButton(
                                            //     onPressed: () => Navigator.push(
                                            //         context,
                                            //         MaterialPageRoute(
                                            //           builder: (context) => Search(
                                            //             querry: word,
                                            //           ),
                                            //         )),
                                            //     child: Text(word),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              )),
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
