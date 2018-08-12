import 'dart:async';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Settings extends StatefulWidget {
  final Function setDarkTheme;
  Settings({Key key, this.setDarkTheme}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _dailyNotification = false;
  bool _darkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

    //Loading counter value on start
  _loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyNotification = (prefs.getBool('dailyNotification') ?? false);
      _darkTheme = (prefs.getBool('darkTheme') ?? false);
    });
  }

  _setPref(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  _setDailyNotification(value) {

  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  _turnOnDailyNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        selectNotification: onSelectNotification);


    // get 3 AM UTC in current time zone
    final DateTime time3amUtc = new DateTime.utc(2018, 1, 1, 3).toLocal();

    var time = new Time(time3amUtc.hour, 0, 0);
    var androidPlatformChannelSpecifics =
        new AndroidNotificationDetails('daily',
            'Daily notification', 'Notify when a new release of daily news briefing is available.');
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'A new release of daily news briefing is available.',
        'Daily news briefing is updated everyday at 8 PM PST.',
        time,
        platformChannelSpecifics);
  }

  _turnOffDailyNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        selectNotification: onSelectNotification);

    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: new ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        children: <Widget>[
          new ListTile(
            title: const Text('Daily notification'),
            subtitle: const Text('Notify you at 8 PM PST when a new release of daily news briefing is available.'),
            onTap: () {  },
            trailing: new Switch(
              value: _dailyNotification,
              onChanged: (bool value) {
                setState(() {
                  _dailyNotification = value;
                });
                _setPref('dailyNotification', value);
                if (value == true) {
                  _turnOnDailyNotification();
                } else {
                  _turnOffDailyNotification();
                }
              },
            ),
          ),
          new ListTile(
            title: const Text('Dark theme'),
            onTap: () {  },
            trailing: new Switch(
              value: _darkTheme,
              onChanged: (bool value) {
                setState(() {
                  _darkTheme = value;
                });
                _setPref('darkTheme', value);
                print(widget.setDarkTheme);
                widget.setDarkTheme(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}