import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'networkrequests/networkrequest.dart';
import '../../../interactor/actions/action_base.dart';
import '../../../interactor/data_stores/network/index.dart';
import '../../../utilities/logging.dart';
import '../../../application_settings.dart';

enum NetworkStatus { online, synchronization }

getActionError(DioError error) {
  switch (error.type) {
    case DioErrorType.CANCEL:
      return Error('network_cancel');
      break;
    case DioErrorType.CONNECT_TIMEOUT:
      return Error('network_timeout');
      break;
    case DioErrorType.DEFAULT:
      return Error('network_default', status: error.response.statusCode);
      break;
    case DioErrorType.RECEIVE_TIMEOUT:
      return Error('network_timeout');
      break;
    case DioErrorType.RESPONSE:
      return Error('network', status: error.response.statusCode);
      break;
    case DioErrorType.SEND_TIMEOUT:
      return Error('network_timeout');
      break;
    default:
      return Error('network_unknown');
  }
}

abstract class INetwork {
  void init();
  Future<R> sendRequest<R>(NetworkRequest request);

  String get authToken;
  String get server;
}

class RestNetwork extends INetwork {
  Dio _dio;
  @override
  String get server => "https://dev.hellodoc.app";
  @override
  String get authToken => "4d66a87c86122c45ad96990b646a795b35110be6";

  RestNetwork() : super();
  @override
  void init() {
    var options = BaseOptions(
        connectTimeout: ApplicationSettings.connectTimeout,
        receiveTimeout: ApplicationSettings.receiveTimeout,
        baseUrl: server);
    _dio = Dio(options);

    if (ApplicationSettings.debug) {
      subscribeToDebugPrint(_dio);
    }
  }

  void subscribeToDebugPrint(Dio dio) {
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      Logger.logNetworkIO("requestHeaders: " + jsonEncode(options.headers));
      if (options.contentType.contains("application/json")) {
        Logger.logNetworkIO("requestData: " + jsonEncode(options.data));
      }
      Logger.logNetworkIO("requestExtra: " + jsonEncode(options.extra));
      Logger.logNetwork("requestPath: " + jsonEncode(options.path));
      Logger.logNetworkIO("ContentType: " + options.contentType.toString());
      Logger.logNetworkIO(
          "requestQuery: " + jsonEncode(options.queryParameters));
      Logger.logNetworkIO("requestUrl: " + jsonEncode(options.baseUrl));

      return options;
    }, onResponse: (Response<dynamic> response) {
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      if (response.request.responseType == ResponseType.json) {
        Logger.logNetworkIO("responseBody: " + encoder.convert(response.data));
      } else {
        Logger.logNetworkIO("responseBody: " + response.toString());
      }
      Logger.logNetworkIO("responseHeader: " + response.headers.toString());
      Logger.logNetworkIO(
          "responseStatusCode: " + jsonEncode(response.statusCode));
      return response;
    }, onError: (DioError e) {
      Logger.logError("errorMessage: " + e.message);
      if (e.response != null) {
        JsonEncoder encoder = JsonEncoder.withIndent('  ');
        if (e.response.request.responseType == ResponseType.json) {
          Logger.logError("responseBody: " + encoder.convert(e.response.data));
        } else {
          Logger.logError("responseBody: " + e.response.toString());
        }
        Logger.logError("responseHeader: " + e.response.headers.toString());
        Logger.logError(
            "responseStatusCode: " + jsonEncode(e.response.statusCode));
      }
      return e;
    }));
  }

  // int counter = 0;
  @override
  Future<R> sendRequest<R>(NetworkRequest request) async {
    var currentDio = _dio;
    if (request.baseUrl != null) {
      var options = BaseOptions(
        baseUrl: request.baseUrl,
        connectTimeout: ApplicationSettings.connectTimeout,
        receiveTimeout: ApplicationSettings.receiveTimeout,
      );
      options.baseUrl = server;
      currentDio = Dio(options);

      if (ApplicationSettings.debug) {
        subscribeToDebugPrint(currentDio);
      }
    }
    Response response;
    Options options = request.options ?? Options();
    if (request.authorized) {
      options.headers["Authorization"] = "Bearer $authToken";
    }
    try {
      switch (request.typeRequest) {
        case TypeRequest.put_request:
          response = await currentDio.put(
            request.url,
            queryParameters: request.queryParameters,
            data: request.data,
            options: options,
          );
          break;
        case TypeRequest.get_request:
          response = await currentDio.get(request.url,
              queryParameters: request.queryParameters, options: options);
          break;
        case TypeRequest.post_request:
          response = await currentDio.post(request.url,
              queryParameters: request.queryParameters,
              data: request.data,
              options: options);
          break;
        case TypeRequest.delete_request:
          response = await currentDio.delete(request.url,
              queryParameters: request.queryParameters,
              data: request.data,
              options: options);
          break;
        case TypeRequest.patch_request:
          response = await currentDio.patch(request.url,
              queryParameters: request.queryParameters,
              data: request.data,
              options: options);
          break;
        default:
      }
    } catch (error) {
      if ((error is DioError)) {
        throw getActionError(error);
      } else {
        throw Error("network_unknown");
      }
    }
    return request.onAnswer(response);
  }
}

// int counter = 0;
