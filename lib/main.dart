import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multilingual_dictionary/serach/search.dart';
import 'package:multilingual_dictionary/shared/data.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Color tertiary = const Color.fromARGB(255, 201, 143, 253);
  Color primary = Colors.lightBlue.shade400;

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: primary.withAlpha(180),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: tertiary,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(ChangeNotifierProvider(
    child: App(
      primary: primary,
      tertiary: tertiary,
    ),
    create: (context) => UserData(context),
  ));
}

class App extends StatelessWidget {
  final Color tertiary;
  final Color primary;
  const App({Key? key, required this.tertiary, required this.primary})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Search(),
      theme: ThemeData(
        fontFamily: "Noto",
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primary,
          onPrimary: Colors.white,
          secondary: tertiary,
          onSecondary: Colors.black,
          tertiary: tertiary,
          onTertiary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          background: Colors.grey.shade100,
          onBackground: Colors.black,
          surface: Colors.grey.shade200,
          onSurface: Colors.black,
        ),
        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline4: TextStyle(
              fontSize: 52.0, fontWeight: FontWeight.bold, color: Colors.black),
          headline6: TextStyle(
              fontSize: 36.0, fontStyle: FontStyle.italic, color: Colors.grey),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UserData extends ChangeNotifier {
  late DatabaseHelper databaseHelper;
  String language = "";
  String translateToEnglish = "";
  UserData(BuildContext context) {
    databaseHelper = DatabaseHelper.init();
  }

  void addLanguage() {
    notifyListeners();
  }

  void removeLanguage() {
    notifyListeners();
  }

  void setWordCollections() {
    notifyListeners();
  }
}
