import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';


class ApiClient {
  String baseUrl = "https://dummyjson.com";
  late Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
      ),
    );
    if (dio.httpClientAdapter is! LogInterceptor) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ));
    }
  }

  Future<Response> getData(String uri) async {
    try {
      Response response = await dio.get(uri);
      return response;
    } catch (e) {
      rethrow;
    }
  }
  Future<Response> postData(String uri, Map<String, dynamic> data) async {
    try {
      Response response = await dio.post(uri, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

}