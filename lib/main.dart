import 'dart:io';
import 'package:nebula/Helpers/config.dart';
import 'package:audio_service/audio_service.dart';
import 'package:nebula/Screens/Library/nowplaying.dart';
import 'package:nebula/Screens/Library/playlists.dart';
import 'package:nebula/Screens/Library/recent.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nebula/Screens/About/about.dart';
import 'package:nebula/Screens/Home/home.dart';
import 'package:nebula/Screens/Settings/setting.dart';
import 'package:nebula/Screens/Search/search.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nebula/Screens/Login/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  try {
    await Hive.openBox('settings');
  } catch (e) {
    print('Failed to open Settings Box');
    print("Error: $e");
    var dir = await getApplicationDocumentsDirectory();
    String dirPath = dir.path;
    String boxName = "settings";
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox("settings");
  }
  try {
    await Hive.openBox('cache');
  } catch (e) {
    print('Failed to open Cache Box');
    print("Error: $e");
    var dir = await getApplicationDocumentsDirectory();
    String dirPath = dir.path;
    String boxName = "cache";
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox("cache");
  }
  try {
    await Hive.openBox('recentlyPlayed');
  } catch (e) {
    print('Failed to open Recent Box');
    print("Error: $e");
    var dir = await getApplicationDocumentsDirectory();
    String dirPath = dir.path;
    String boxName = "recentlyPlayed";
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox("recentlyPlayed");
  }
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Failed to initialize Firebase');
  }

  Paint.enableDithering = true;
  runApp(MyApp());
  // SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      setState(() {});
    });
    analytics.logAppOpen();
  }

  initialFuntion() {
    return Hive.box('settings').get('name') != null
        ? AudioServiceWidget(child: HomePage())
        : AuthScreen();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'nebula',
      themeMode: currentTheme.currentTheme(), //system,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: currentTheme.currentColor(),
          cursorColor: currentTheme.currentColor(),
          selectionColor: currentTheme.currentColor(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: currentTheme.currentColor())),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        accentColor: currentTheme.currentColor(),
      ),

      darkTheme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: currentTheme.currentColor(),
          cursorColor: currentTheme.currentColor(),
          selectionColor: currentTheme.currentColor(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: currentTheme.currentColor())),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        canvasColor: Colors.grey[900],
        cardColor: Colors.grey[850],
        accentColor: currentTheme.currentColor(),
      ),
      routes: {
        '/': (context) => initialFuntion(),
        '/setting': (context) => SettingPage(),
        '/search': (context) => SearchPage(),
        '/about': (context) => AboutScreen(),
        '/playlists': (context) => PlaylistScreen(),
        '/nowplaying': (context) => NowPlaying(),
        '/recent': (context) => RecentlyPlayed(),
      },
    );
  }
}
