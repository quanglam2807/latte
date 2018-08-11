import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'about.dart';
import 'link-text-span.dart';

Future<List<Widget>> showLoading() async {
  return null;
}

Future<List<Widget>> fetchContent(DateTime date) async {
  String dateStr = new DateFormat.y().format(date) 
    + '_' + new DateFormat.MMMM().format(date)
    + '_' + new DateFormat.d().format(date);
  final response =
      await http.get('https://en.wikipedia.org/wiki/Portal:Current_events/' + dateStr + '?action=raw');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    return rawToWidgets(response.body, date);
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

String titlize(String str) {
  String newStr = str;
  for(int i = 0; i < str.length; i++) {
    if (i == 0) {
      newStr = newStr[0].toUpperCase() + newStr.substring(1);
    } else if (str[i - 1] == ' ') {
      newStr = newStr.substring(0, i) + newStr[i].toUpperCase() + newStr.substring(i + 1);
    }
  }
  return newStr;
}

List<TextSpan> rawToTextSpans(String str) {
  // Type 0: normal text
  // Type 1: Wikipedia link with same name
  // Type 2: Wikipedia link with different name
  // Type 3: Source

  List<String> parts = [];
  String currentPart = '';
  for (int i = 0; i < str.length; i++) {
    if (str[i] == '[' || str[i] == ']' || str[i] == '{' || str[i] == '}') {
      if (currentPart.length > 0 && currentPart != '[' && currentPart != '{') {
        parts.add(currentPart);
      }
      currentPart = str[i] == '[' || str[i] == '{' ? str[i] : '';
    } else {
      currentPart = currentPart + str[i];
    }
  }


  List<TextSpan> children = [];
  for (int i = 0; i < parts.length; i++) {
    String part = parts[i];

    if (part.startsWith('[')) {
      // Type 2
      if (part.contains('|')) {
        final List<String> components = part.substring(1).split('|');
        final String wikipediaTitle = components[0];
        final String title = components[1];
        children.add(LinkTextSpan(
          text: title,
          url: Uri.encodeFull('https://en.wikipedia.org/wiki/' + wikipediaTitle),
        ));
      } else if (part.contains('http')) {
        List<String> components = part.substring(1).split(' ');
        final String url = components[0];
        components[0] = '';
        final String title = components.join(' ');
        children.add(LinkTextSpan(
          text: title,
          url: url,
        ));
        // f
      } else {
        final String title = part.substring(1);
        children.add(LinkTextSpan(
          text: title,
          url: Uri.encodeFull('https://en.wikipedia.org/wiki/' + title),
        ));
      }
    } else if (part.startsWith('{')) {
      List<String> components = part.split('|');
      children.add(TextSpan(text: components[1]));
    } else {
      children.add(TextSpan(text: part));
    }
  }

  return children;
}

List<Widget> rawToWidgets(String rawContent, DateTime date) {
  final widgets = new List<Widget>();

  final lines = rawContent.split('\n');

  for (String line in lines) {
    if (line.startsWith(';')) {
      String t = line
        .substring(1)
        .replaceAll(' and ', ' & ')
        .trim();
      t = titlize(t);

      widgets.add(Container(
        child: Text(
          t,
          style: headingTextStyle,
        ),
        margin: new EdgeInsets.only(top: 16.0)
      ));
    } else if (line.startsWith('*') && line.contains('.')) {
      String t = line
        .replaceAll('\'\'', '');

      if (line.startsWith('**')) {
        t = t.substring(2);
      } else {
        t = t.substring(1);
      }

      List<TextSpan> textSpans = rawToTextSpans(t);

      widgets.add(Container(
        child: Text.rich(
          TextSpan(
            children: textSpans,
            style: contentTextStyle,
          ),
        ),
        margin: new EdgeInsets.only(bottom: 16.0)
      ));
    }
  }

  String dateStr = new DateFormat.y().format(date) 
    + '_' + new DateFormat.MMMM().format(date) 
    + '_' + new DateFormat.d().format(date);

  widgets.add(Text.rich(
    TextSpan(children: <TextSpan>[
      TextSpan(text: 'Original text authored by '),
      LinkTextSpan(
        text: 'Wikipedia contributors',
        url: 'https://en.wikipedia.org/wiki/Portal:Current_events/' + dateStr + '?action=history',
      ),
      TextSpan(text: ' and available under the '),
      LinkTextSpan(
        text: 'Creative Commons Attribution-ShareAlike License',
        url: 'https://creativecommons.org/licenses/by-sa/3.0/us/',
      ),
      TextSpan(text: '. Latte is updated daily at 8:00 PM PST.'),
    ]),
    style: TextStyle(
      fontSize: 11.0,
    )
  ));

  return widgets;
}

DateTime getLatestDate() {
  final DateTime now = new DateTime.now().toUtc();

  final DateTime latest = now.hour < 3 ? 
      new DateTime.now().toUtc().subtract(new Duration(days: 2))
    : new DateTime.now().toUtc().subtract(new Duration(days: 1));

  return latest;
}

void main() => runApp(MyApp());

TextStyle headingTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 20.0,
);

TextStyle contentTextStyle = TextStyle(
  fontSize: 15.0,
  height: 1.1,
);

class Main extends StatefulWidget {
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  Future<List<Widget>> _response;

  DateTime currentDate = getLatestDate();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: new DateTime(2010, 1),
      lastDate: getLatestDate(),
    );
    if (picked != null && picked != currentDate)
      setState(() {
        currentDate = picked;
      });
      _loadContent();
  }

  void _loadContent() {
    print(getLatestDate());
    setState(() {
      _response = showLoading();

      _response
        .then((w) {
          return new Future.delayed(const Duration(milliseconds: 200), () => "200 miliseconds");
        }).then((w) {
          setState(() {
            _response = fetchContent(currentDate);
          });
        });
    });
  }

  void _select(Choice choice) {
    if (choice.title == 'Refresh') {
      _loadContent();
    }
    if (choice.title == 'About') {
      showLatteAboutDialog(context);
    }
  }

  @override
  initState() {
    super.initState();
    _loadContent();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(new DateFormat.yMMMMEEEEd().format(currentDate)),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.calendar_today),
              tooltip: 'Archive',
              onPressed: () { _selectDate(context); },
            ),
            // overflow menu
            PopupMenuButton<Choice>(
              onSelected: _select,
              itemBuilder: (BuildContext context) {
                return choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                    value: choice,
                    child: Text(choice.title),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Container(
          child: FutureBuilder<List<Widget>>(
            future: _response,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: snapshot.data
                  ),
                  padding: new EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    children: <Widget>[
                      Text("${snapshot.error}"),
                      RaisedButton(
                        child: Text('Try Again'),
                        onPressed: () {
                          _loadContent();
                        }
                      )
                    ]
                  )
                );
              }

              // By default, show a loading spinner
              return Center(
                child: CircularProgressIndicator()
              );
            },
          ),
        ),
      );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Refresh', icon: Icons.refresh),
  const Choice(title: 'About', icon: Icons.info),
];


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Latte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: Main()
    );
  }
}