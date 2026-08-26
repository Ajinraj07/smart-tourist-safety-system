import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        throw ServerException(
          message: e.response?.data?['detail'] ?? e.response?.data?['message'] ?? e.message ?? 'Unknown error',
          statusCode: e.response?.statusCode,
        );
      },
    ));
  }

  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(url, queryParameters: queryParameters);
  }

  Future<Response> post(String url, {dynamic data}) async {
    return await dio.post(url, data: data);
  }

  Future<Response> put(String url, {dynamic data}) async {
    return await dio.put(url, data: data);
  }

  Future<Response> delete(String url) async {
    return await dio.delete(url);
  }
}
