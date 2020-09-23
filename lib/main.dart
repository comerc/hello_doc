import 'package:flutter/material.dart';
import 'presenters/presenter_provider.dart';
import 'views/index.dart' as views;
import 'presenters/index.dart' as presenters;

// + исправить варнинги pedantic
// + установить MaterialApp.title
// + увеличить расстояние между интервалами внутри дня
// + применить золотое сечение для пропорций полей ввода
// + реализовать elevation для appBar
// + добавить анимацию для блока расписания на день
// TODO: - клик по ряду день недели c InkWell
// TODO: - bot_toast для ошибок вне контекста Scaffold
// TODO: - нет обратной связи об успешной записи изменений
// TODO: - отключать кнопку "Готово", пока выполняется запись
// TODO: - точки в ползунках?
// TODO: кнопка "Готово" сливается по цвету - поменять?
// TODO: форма в диалоге, которая закрывается после записи
// TODO: проверить SafeArea для .appBar с помощью device_preview
// TODO: import.dart
// TODO: StartScreen для initialRoute
// TODO: MediaQueryWrap
// TODO: appBarTheme
// TODO: как удалить интервал внутри дня, чтобы не стирать весь день?
// TODO: flutter doctor -v выводит "Channel unknown"
// TODO: расположение контролов по сетке 8 или 16

void main() {
  runApp(
    PresenterProvider<presenters.Schedule>(
      child: views.Schedule(),
      presenter: presenters.Schedule(),
    ),
  );
}
