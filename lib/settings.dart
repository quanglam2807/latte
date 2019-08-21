import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// get 3 AM UTC in current time zone
final DateTime time3amUtc = new DateTime.utc(2018, 1, 1, 3).toLocal();
var time = new Time(time3amUtc.hour, 0, 0);
var formatter = new DateFormat.jm();
String formattedTime = formatter.format(time3amUtc);

class Settings extends StatefulWidget {
  final Function setDarkTheme;
  Settings({Key key, this.setDarkTheme}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _dailyNotification = false;
  bool _darkTheme = false;
  bool _inAppBrowser = false;

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
      _inAppBrowser = (prefs.getBool('inAppBrowser') ?? false);
    });
  }

  _setPref(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
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

    var androidPlatformChannelSpecifics =
        new AndroidNotificationDetails('daily',
            'Daily Notification', 'Notify when a new release of daily news briefing is available.');
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'A new release of daily news briefing is available.',
        'Daily news briefing is updated everyday at $formattedTime.',
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
    // get 3 AM UTC in current time zone
    final DateTime time3amUtc = new DateTime.utc(2018, 1, 1, 3).toLocal();
    var formatter = new DateFormat.jm();
    String formattedTime = formatter.format(time3amUtc);
    String dailyNotificationSubtitle = 'Notify you at $formattedTime when a new release of daily news briefing is available.';

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: new ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        children: <Widget>[
          new ListTile(
            title: const Text('Daily Notification'),
            subtitle: Text(dailyNotificationSubtitle),
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
            title: const Text('Dark Theme'),
            onTap: () {  },
            trailing: new Switch(
              value: _darkTheme,
              onChanged: (bool value) {
                setState(() {
                  _darkTheme = value;
                });
                _setPref('darkTheme', value);
                widget.setDarkTheme(value);
              },
            ),
          ),
          new ListTile(
            title: const Text('In-app Browser'),
            onTap: () {  },
            trailing: new Switch(
              value: _inAppBrowser,
              onChanged: (bool value) {
                setState(() {
                  _inAppBrowser = value;
                });
                _setPref('inAppBrowser', value);
              },
            ),
          ),
        ],
      ),
    );
  }
}