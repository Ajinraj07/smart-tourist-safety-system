class PlaceModel {
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
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
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
