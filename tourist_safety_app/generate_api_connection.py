import os

base_dir = r"c:\Users\AJINRAJ\Downloads\Whisk Downloads\tourist_safety_v1\tourist_safety_app\lib"

files = {
    # Core Constants
    "core/constants/api_constants.dart": """class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000/api/';
  static const String loginEndpoint = 'auth/login/';
  static const String registerEndpoint = 'auth/register/';
  static const String refreshEndpoint = 'auth/refresh/';
  static const String placesEndpoint = 'core/places/';
  static const String dangerZonesEndpoint = 'core/danger-zones/';
  static const String nearbyDataEndpoint = 'alerts/nearby-data/';
  static const String sendSosEndpoint = 'alerts/send-sos/';
  static const String checkDangerZoneEndpoint = 'alerts/check-danger-zone/';
}
""",

    # Core Error Handling
    "core/error/exceptions.dart": """class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (Status Code: $statusCode)';
}
""",

    # Core Network Dio Client
    "core/network/dio_client.dart": """import 'package:dio/dio.dart';
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
""",

    # Auth Model
    "features/auth/data/models/user_model.dart": """class UserModel {
  final String username;
  final String email;

  UserModel({required this.username, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
""",

    # Auth Repository
    "features/auth/data/repositories/auth_repository.dart": """import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  Future<void> login(String username, String password) async {
    final response = await _dioClient.post(
      ApiConstants.loginEndpoint,
      data: {'username': username, 'password': password},
    );
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', response.data['access']);
    await prefs.setString('refresh_token', response.data['refresh']);
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
""",

    # Auth Provider
    "features/auth/presentation/providers/auth_provider.dart": """import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/network/dio_client.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioClientProvider));
});

final authStateProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<bool> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(false) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    state = await _repository.isAuthenticated();
  }

  Future<void> login(String username, String password) async {
    await _repository.login(username, password);
    state = true;
  }

  Future<void> logout() async {
    await _repository.logout();
    state = false;
  }
}
""",

    # Place Model
    "features/places/data/models/place_model.dart": """class PlaceModel {
  final int id;
  final String name;
  final String type;
  final String address;
  final double latitude;
  final double longitude;
  final String description;

  PlaceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      address: json['address'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'description': description,
  };
}
""",

    # Place Repository
    "features/places/data/repositories/place_repository.dart": """import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/place_model.dart';

class PlaceRepository {
  final DioClient _dioClient;

  PlaceRepository(this._dioClient);

  Future<List<PlaceModel>> getPlaces() async {
    final response = await _dioClient.get(ApiConstants.placesEndpoint);
    return (response.data as List).map((json) => PlaceModel.fromJson(json)).toList();
  }

  Future<PlaceModel> getPlace(int id) async {
    final response = await _dioClient.get('${ApiConstants.placesEndpoint}$id/');
    return PlaceModel.fromJson(response.data);
  }

  Future<PlaceModel> createPlace(PlaceModel place) async {
    final response = await _dioClient.post(ApiConstants.placesEndpoint, data: place.toJson());
    return PlaceModel.fromJson(response.data);
  }

  Future<PlaceModel> updatePlace(int id, PlaceModel place) async {
    final response = await _dioClient.put('${ApiConstants.placesEndpoint}$id/', data: place.toJson());
    return PlaceModel.fromJson(response.data);
  }

  Future<void> deletePlace(int id) async {
    await _dioClient.delete('${ApiConstants.placesEndpoint}$id/');
  }
}
""",

    # Place Provider
    "features/places/presentation/providers/place_provider.dart": """import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/place_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/place_model.dart';

final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return PlaceRepository(ref.watch(dioClientProvider));
});

final placesProvider = FutureProvider<List<PlaceModel>>((ref) async {
  final repository = ref.watch(placeRepositoryProvider);
  return await repository.getPlaces();
});
""",

    # Danger Zone Model
    "features/danger_zones/data/models/danger_zone_model.dart": """class DangerZoneModel {
  final int id;
  final String name;
  final String riskType;
  final String severity;
  final double latitude;
  final double longitude;
  final String additionalDetails;
  final int radius;

  DangerZoneModel({
    required this.id,
    required this.name,
    required this.riskType,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.additionalDetails,
    required this.radius,
  });

  factory DangerZoneModel.fromJson(Map<String, dynamic> json) {
    return DangerZoneModel(
      id: json['id'],
      name: json['name'],
      riskType: json['risk_type'],
      severity: json['severity'],
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      additionalDetails: json['additional_details'] ?? '',
      radius: json['radius'] ?? 500,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'risk_type': riskType,
    'severity': severity,
    'latitude': latitude,
    'longitude': longitude,
    'additional_details': additionalDetails,
    'radius': radius,
  };
}
""",

    # Danger Zone Repository
    "features/danger_zones/data/repositories/danger_zone_repository.dart": """import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/danger_zone_model.dart';

class DangerZoneRepository {
  final DioClient _dioClient;

  DangerZoneRepository(this._dioClient);

  Future<List<DangerZoneModel>> getDangerZones() async {
    final response = await _dioClient.get(ApiConstants.dangerZonesEndpoint);
    return (response.data as List).map((json) => DangerZoneModel.fromJson(json)).toList();
  }

  Future<DangerZoneModel> createDangerZone(DangerZoneModel zone) async {
    final response = await _dioClient.post(ApiConstants.dangerZonesEndpoint, data: zone.toJson());
    return DangerZoneModel.fromJson(response.data);
  }

  Future<DangerZoneModel> updateDangerZone(int id, DangerZoneModel zone) async {
    final response = await _dioClient.put('${ApiConstants.dangerZonesEndpoint}$id/', data: zone.toJson());
    return DangerZoneModel.fromJson(response.data);
  }

  Future<void> deleteDangerZone(int id) async {
    await _dioClient.delete('${ApiConstants.dangerZonesEndpoint}$id/');
  }
}
""",

    # Danger Zone Provider
    "features/danger_zones/presentation/providers/danger_zone_provider.dart": """import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/danger_zone_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/danger_zone_model.dart';

final dangerZoneRepositoryProvider = Provider<DangerZoneRepository>((ref) {
  return DangerZoneRepository(ref.watch(dioClientProvider));
});

final dangerZonesProvider = FutureProvider<List<DangerZoneModel>>((ref) async {
  final repository = ref.watch(dangerZoneRepositoryProvider);
  return await repository.getDangerZones();
});
""",

    # Alerts Repository
    "features/alerts/data/repositories/alerts_repository.dart": """import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class AlertsRepository {
  final DioClient _dioClient;

  AlertsRepository(this._dioClient);

  Future<Map<String, dynamic>> getNearbyData(double lat, double lon) async {
    final response = await _dioClient.get(
      ApiConstants.nearbyDataEndpoint,
      queryParameters: {'lat': lat, 'lon': lon},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> sendSos(double lat, double lon) async {
    final response = await _dioClient.post(
      ApiConstants.sendSosEndpoint,
      data: {'lat': lat, 'lon': lon},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> checkDangerZone(double lat, double lon) async {
    final response = await _dioClient.post(
      ApiConstants.checkDangerZoneEndpoint,
      data: {'latitude': lat, 'longitude': lon},
    );
    return response.data;
  }
}
""",

    # Alerts Provider
    "features/alerts/presentation/providers/alerts_provider.dart": """import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/alerts_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepository(ref.watch(dioClientProvider));
});
"""
}

for rel_path, content in files.items():
    full_path = os.path.join(base_dir, rel_path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w", encoding="utf-8") as file:
        file.write(content)

print("Generated API connection code across the Clean Architecture folders.")
