import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

import '../models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  Future<UserModel> login(String username, String password) async {
    final response = await _dioClient.post(
      ApiConstants.loginEndpoint,
      data: {'username': username, 'password': password},
    );
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', response.data['access']);
    await prefs.setString('refresh_token', response.data['refresh']);

    return await fetchUser();
  }

  Future<UserModel> fetchUser() async {
    final response = await _dioClient.get(ApiConstants.authMeEndpoint);
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> updateProfile(String username, String? password) async {
    final data = <String, dynamic>{'username': username};
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }
    
    final response = await _dioClient.put(
      ApiConstants.authMeEndpoint,
      data: data,
    );
    return UserModel.fromJson(response.data);
  }

  Future<void> register(String username, String email, String password) async {
    await _dioClient.post(
      ApiConstants.registerEndpoint,
      data: {'username': username, 'email': email, 'password': password},
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }
}
