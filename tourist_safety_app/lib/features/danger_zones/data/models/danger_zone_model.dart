class DangerZoneModel {
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
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
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
