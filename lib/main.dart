import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'views/index.dart' as views;
import 'presenters/index.dart' as presenters;
import 'presenters/presenter_provider.dart';

void main() {
  runApp(PresenterProvider<presenters.Schedule>(
    child: views.Schedule(),
    presenter: presenters.Schedule(),
  ));
}
