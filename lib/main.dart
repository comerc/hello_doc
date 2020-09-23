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
// TODO: нет обратной связи об успешной записи изменений
// TODO: отключать кнопку "ГОТОВО", пока выполняется запись
// TODO: как удалить интервал внутри дня, чтобы не стирать весь день?
// TODO: исправить варнинги pedantic

void main() {
  runApp(PresenterProvider<presenters.Schedule>(
    child: views.Schedule(),
    presenter: presenters.Schedule(),
  ));
}
