import 'utilities/logging.dart';

class ApplicationSettings {
  static const String appName = 'Hello Doc!';
  static const int connectTimeout = 3000;
  static const int receiveTimeout = 3000;
  static const bool debug = true;
  static final Set<LogType> loggingLayers = <LogType>{
    // LogType.Network,
    // LogType.NetworkIO,
    // LogType.NetworkError,
    // LogType.Entities,
    // LogType.Presenter,
    // // LogType.Stomp, // TODO: зачем? (узнать у автора)
    // LogType.Accessor,
    // LogType.Error,
    LogType.Andre,
  };
  static const String copyrightString = '';
}
