import '../../../../core/network/dio_client.dart';
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

  Future<List<dynamic>> getAlerts() async {
    final response = await _dioClient.get(ApiConstants.alertsEndpoint);
    return response.data['alerts'] ?? [];
  }
}
