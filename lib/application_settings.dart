import 'utilities/logging.dart';

class ApplicationSettings {
  static const String app_name = "Hello Doc!";
  static const int connectTimeout = 3000;
  static const int receiveTimeout = 3000;
  static const bool debug = true;
  static final Set<LogType> loggingLayers = Set<LogType>.from([
    // LogType.Network,
    // LogType.NetworkIO,
    // LogType.NetworkError,
    // LogType.Entities,
    // LogType.Presenter,
    // LogType.Stomp,
    // LogType.Accessor,
    // LogType.Error,
    LogType.Andre,
  ]);
  static const String copyrightString = "";
}
