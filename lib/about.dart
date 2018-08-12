// https://raw.githubusercontent.com/flutter/flutter/bf3bd7667f07709d0b817ebfcb6972782cfef637/examples/flutter_gallery/lib/gallery/about.dart

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'link-text-span.dart';

Future<Null> showLatteAboutDialog(BuildContext context) async {
  final ThemeData themeData = Theme.of(context);
  final TextStyle aboutTextStyle = themeData.textTheme.body2;

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  showAboutDialog(
    context: context,
    applicationName: 'Latte',
    applicationVersion: packageInfo.version,
    applicationLegalese: '© Quang Lam',
    children: <Widget>[
      new Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: new RichText(
          text: new TextSpan(
            children: <TextSpan>[
              new LinkTextSpan(
                url: 'https://quanglam.me/latte',
              ),
              new TextSpan(
                style: aboutTextStyle,
                text: '.\n\nTo see the source code for this app, please visit the ',
              ),
              new LinkTextSpan(
                url: 'https://github.com/quanglam2807/latte',
                text: 'latte github repo',
              ),
              new TextSpan(
                style: aboutTextStyle,
                text: '.',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}