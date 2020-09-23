import 'package:dio/dio.dart' as dio;

enum TypeRequest {
  post_request,
  get_request,
  put_request,
  delete_request,
  patch_request
}

abstract class NetworkRequest<R> {
  R onAnswer(dio.Response answer);

  String get url;
  String get baseUrl => null;
  dynamic get data;
  Map<String, dynamic> get queryParameters => {};
  dio.Options get options;
  TypeRequest get typeRequest;
  bool get authorized => false;
  bool get withTenant => true;
}
