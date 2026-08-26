import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api/';
  static const String loginEndpoint = 'auth/login/';
  static const String registerEndpoint = 'auth/register/';
  static const String refreshEndpoint = 'auth/refresh/';
  static const String authMeEndpoint = 'auth/me/';
  static const String placesEndpoint = 'core/places/';
  static const String dangerZonesEndpoint = 'core/danger-zones/';
  static const String nearbyDataEndpoint = 'alerts/nearby-data/';
  static const String sendSosEndpoint = 'alerts/send-sos/';
  static const String checkDangerZoneEndpoint = 'alerts/check-danger-zone/';
  static const String alertsEndpoint = 'alerts/';
  static const String bulkUploadEndpoint = 'core/bulk-upload/';
}
