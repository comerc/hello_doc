import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'views/index.dart' as views;
import 'presenters/index.dart' as presenters;
import 'presenters/presenter_provider.dart';

// TODO: vertical orientation
// TODO: скроллировать "Готово"
// TODO: header elevation
// TODO: форма в диалоге
// TODO: сепараторы
// TODO: AnimatedBox
// TODO: device_preview
// TODO: SafeArea
// TODO: bot_toast для ошибок вне контекста Scaffold
// TODO: import.dart
// TODO: StartScreen для initialRoute
// TODO: MediaQueryWrap
// TODO: appBarTheme

void main() {
  runApp(PresenterProvider<presenters.Schedule>(
    child: views.Schedule(),
    presenter: presenters.Schedule(),
  ));
}
