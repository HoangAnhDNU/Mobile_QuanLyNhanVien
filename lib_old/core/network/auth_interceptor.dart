import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  String? _accessToken;
  String? _refreshToken;

  void setTokens({String? accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_accessToken != null) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && _refreshToken != null) {
      try {
        final dio = Dio();
        final response = await dio.post(
          '${err.requestOptions.baseUrl}/auth/refresh',
          data: {'refreshToken': _refreshToken},
        );

        _accessToken = response.data['accessToken'] as String;

        err.requestOptions.headers['Authorization'] = 'Bearer $_accessToken';
        final retryResponse = await dio.fetch(err.requestOptions);
        handler.resolve(retryResponse);
        return;
      } catch (_) {
        _accessToken = null;
        _refreshToken = null;
      }
    }
    handler.next(err);
  }
}
