import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/danger_zone_model.dart';

class DangerZoneRepository {
  final DioClient _dioClient;

  DangerZoneRepository(this._dioClient);

  Future<List<DangerZoneModel>> getDangerZones() async {
    final response = await _dioClient.get(ApiConstants.dangerZonesEndpoint);
    final data = response.data;
    if (data is Map && data.containsKey('results')) {
      return (data['results'] as List).map((json) => DangerZoneModel.fromJson(json)).toList();
    }
    return (data as List).map((json) => DangerZoneModel.fromJson(json)).toList();
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
