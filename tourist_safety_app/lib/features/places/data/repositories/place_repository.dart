import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/place_model.dart';

class PlaceRepository {
  final DioClient _dioClient;

  PlaceRepository(this._dioClient);

  Future<List<PlaceModel>> getPlaces() async {
    final response = await _dioClient.get(ApiConstants.placesEndpoint);
    final data = response.data;
    if (data is Map && data.containsKey('results')) {
      return (data['results'] as List).map((json) => PlaceModel.fromJson(json)).toList();
    }
    return (data as List).map((json) => PlaceModel.fromJson(json)).toList();
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
