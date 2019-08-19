// https://raw.githubusercontent.com/flutter/flutter/bf3bd7667f07709d0b817ebfcb6972782cfef637/examples/flutter_gallery/lib/gallery/about.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkTextSpan extends TextSpan {

  // Beware!
  //
  // This class is only safe because the TapGestureRecognizer is not
  // given a deadline and therefore never allocates any resources.
  //
  // In any other situation -- setting a deadline, using any of the less trivial
  // recognizers, etc -- you would have to manage the gesture recognizer's
  // lifetime and call dispose() when the TextSpan was no longer being rendered.
  //
  // Since TextSpan itself is @immutable, this means that you would have to
  // manage the recognizer from outside the TextSpan, e.g. in the State of a
  // stateful widget that then hands the recognizer to the TextSpan.

  LinkTextSpan({ String url, String text }) : super(
    style: TextStyle(color: Colors.blue[500]),
    text: text ?? url,
    recognizer: new TapGestureRecognizer()..onTap = () {
      launch(url);
    }
  );
}
