import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class AdminRepository {
  final DioClient _dioClient;

  AdminRepository(this._dioClient);

  String get _adminApiBase => ApiConstants.baseUrl.replaceAll('/api/', '/accounts/admin/api/');

  Future<Map<String, dynamic>> fetchDashboardStats() async {
    final response = await _dioClient.get('${_adminApiBase}dashboard-stats/');
    return response.data['stats'];
  }

  Future<List<dynamic>> fetchLiveTourists() async {
    final response = await _dioClient.get('${_adminApiBase}live-tourists/');
    return response.data['tourists'];
  }

  Future<List<dynamic>> fetchLiveSos() async {
    final response = await _dioClient.get('${_adminApiBase}live-sos/');
    return response.data['sos_alerts'];
  }

  Future<List<dynamic>> fetchAllSos() async {
    final response = await _dioClient.get('${_adminApiBase}live-sos/?all=true');
    return response.data['sos_alerts'];
  }

  Future<void> updateSosStatus(int sosId, String status) async {
    await _dioClient.post('${_adminApiBase}update-sos-status/', data: {
      'sos_id': sosId,
      'status': status,
    });
  }

  Future<void> deleteTourist(int touristId) async {
    await _dioClient.delete('${_adminApiBase}delete-tourist/$touristId/');
  }

  Future<Map<String, dynamic>> bulkUpload(String uploadType, List<int> fileBytes, String fileName) async {
    final formData = FormData.fromMap({
      'upload_type': uploadType,
      'csv_file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    
    final response = await _dioClient.post(ApiConstants.bulkUploadEndpoint, data: formData);
    return response.data;
  }
}
