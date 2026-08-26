import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final locationProvider = NotifierProvider<LocationNotifier, Position?>(() {
  return LocationNotifier();
});

bool isValidCoordinate(double? lat, double? lon) {
  if (lat == null || lon == null) return false;
  if (lat == 0.0 && lon == 0.0) return false;
  if (lat < -90 || lat > 90) return false;
  if (lon < -180 || lon > 180) return false;
  return true;
}

class MapDestinationNotifier extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() => null;

  Future<void> setDestination(Map<String, dynamic>? placeInfo) async {
    if (placeInfo == null) {
      state = null;
      return;
    }
    
    state = {...placeInfo, 'isLoading': true};

    try {
      final pos = ref.read(locationProvider);
      
      final startLat = pos?.latitude ?? 10.5276;
      final startLng = pos?.longitude ?? 76.2144;
      final destLat = double.tryParse(placeInfo['latitude'].toString());
      final destLng = double.tryParse(placeInfo['longitude'].toString());
      
      if (!isValidCoordinate(startLat, startLng) || !isValidCoordinate(destLat, destLng)) {
        state = {
          ...placeInfo,
          'error': 'Invalid location — cannot draw route',
          'isLoading': false,
        };
        return;
      }
        
        final dio = Dio();
        final targetUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLng&destination=$destLat,$destLng&mode=driving&key=YOUR_GOOGLE_MAPS_API_KEY";
        final url = "https://corsproxy.io/?" + Uri.encodeComponent(targetUrl);
        final response = await dio.get(url);
        final data = response.data;

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          List<LatLng> routePoints = PolylinePoints().decodePolyline(route['overview_polyline']['points'])
              .map((p) => LatLng(p.latitude, p.longitude)).toList();
          
          String distanceStr = leg['distance']['text'];
          double distanceKm = double.tryParse(distanceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          
          String durationStr = leg['duration']['text'];
          int durationMin = int.tryParse(durationStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          
          List<dynamic> steps = leg['steps'];

          state = {
            ...placeInfo,
            'routePoints': routePoints,
            'distance': distanceKm,
            'duration': durationMin,
            'distanceText': distanceStr,
            'durationText': durationStr,
            'steps': steps,
            'isLoading': false,
          };
        } else {
          state = {
            ...placeInfo,
            'error': data['error_message'] ?? 'Routing failed.',
            'isLoading': false,
          };
        }

    } catch (e) {
      print("Routing error: $e");
      state = {
        ...placeInfo,
        'error': 'Routing failed. Please check connection.',
        'isLoading': false,
      };
    }
  }
}

final mapDestinationProvider = NotifierProvider<MapDestinationNotifier, Map<String, dynamic>?>(() {
  return MapDestinationNotifier();
});

class RiskStatusNotifier extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() => null;

  void updateStatus(Map<String, dynamic>? data) {
    state = data;
  }
}

final riskStatusProvider = NotifierProvider<RiskStatusNotifier, Map<String, dynamic>?>(() {
  return RiskStatusNotifier();
});

class LocationNotifier extends Notifier<Position?> {
  StreamSubscription<Position>? _positionStream;
  late final DioClient _dioClient;
  int? _currentDangerZoneId;

  @override
  Position? build() {
    _dioClient = ref.watch(dioClientProvider);
    _initTracking();
    return null;
  }

  Future<void> _initTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Get initial position immediately
    final initialPos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    state = initialPos;
    _checkDangerZone(initialPos.latitude, initialPos.longitude);

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      state = position;
      _checkDangerZone(position.latitude, position.longitude);
    });
  }

  Future<void> _checkDangerZone(double lat, double lon) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.checkDangerZoneEndpoint,
        data: {'latitude': lat, 'longitude': lon},
      );
      
      final data = response.data;
      ref.read(riskStatusProvider.notifier).updateStatus(data);
      
      if (data['inside'] == true && _currentDangerZoneId != data['zone_id']) {
        _currentDangerZoneId = data['zone_id'];
        // TODO: Show danger modal or trigger alert beep
      } else if (data['inside'] == false) {
        _currentDangerZoneId = null;
      }
    } catch (e) {
      // print('Geofence error: $e');
    }
  }

  void cancelTracking() {
    _positionStream?.cancel();
  }
}
