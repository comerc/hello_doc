import 'package:flutter/widgets.dart';
import '../application_settings.dart';

enum LogType {
  Network,
  NetworkIO,
  NetworkError,
  Accessor,
  Entities,
  Presenter,
  Error,
  Andre,
}

class Logger {
  static void log(Object object, {LogType type}) {
    if (!ApplicationSettings.debug) return;

    if (ApplicationSettings.loggingLayers == null || type == null) {
      debugPrint(object.toString());
    } else if (type != null &&
        ApplicationSettings.loggingLayers.contains(type)) {
      var tag = type.toString().replaceAll('LogType.', '');
      debugPrint('$tag: $object');
    }
  }

  static void logNetwork(Object object) {
    log(object, type: LogType.Network);
  }

  static void logEntities(Object object) {
    log(object, type: LogType.Entities);
  }

  static void logNetworkIO(Object object) {
    log(object, type: LogType.NetworkIO);
  }

  static void logNetworkError(Object object) {
    log(object, type: LogType.NetworkError);
  }

  static void logPresenter(Object object) {
    log(object, type: LogType.Presenter);
  }

  static void logAccessor(Object object) {
    log(object, type: LogType.Accessor);
  }

  static void logError(Object object) {
    // TODO: сообщение об ошибке выводить более информативно
    log(object, type: LogType.Error);
  }

  static void logAndre(Object object) {
    log(object, type: LogType.Andre);
  }
}
