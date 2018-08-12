import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  _loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkTheme = (prefs.getBool('darkTheme') ?? false);
    });
  }

  _setDarkTheme(value) async {
    setState(() {
      _darkTheme = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Latte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _darkTheme ? Brightness.dark : Brightness.light,
        primaryColor: _darkTheme ? null : Colors.white,
      ),
      home: Home(setDarkTheme: _setDarkTheme,),
    );
  }
}