import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../places/presentation/screens/places_screen.dart';
import '../../../danger_zones/presentation/screens/danger_zones_screen.dart';
import '../../../alerts/presentation/screens/risk_level_screen.dart';
import '../../../alerts/presentation/screens/notifications_screen.dart';
import '../../../auth/presentation/screens/profile_screen.dart';
import '../../../alerts/presentation/providers/alerts_provider.dart';
import '../../../maps/presentation/providers/location_provider.dart';
import '../../../places/presentation/providers/place_provider.dart';
import '../../../danger_zones/presentation/providers/danger_zone_provider.dart';
import 'package:geolocator/geolocator.dart';

class TouristDashboardScreen extends ConsumerStatefulWidget {
  const TouristDashboardScreen({super.key});

  @override
  ConsumerState<TouristDashboardScreen> createState() => _TouristDashboardScreenState();
}

class _TouristDashboardScreenState extends ConsumerState<TouristDashboardScreen> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _hospitalIcon;
  BitmapDescriptor? _policeIcon;
  
  final LatLng _initialCenter = const LatLng(10.5276, 76.2144); // Thrissur default

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    _hospitalIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)), 
      'assets/icons/hospital.png',
    );
    _policeIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)), 
      'assets/icons/police.png',
    );
    if (mounted) setState(() {});
  }

  Future<void> _sendSOS() async {
    try {
      final pos = ref.read(locationProvider);
      if (pos == null) throw Exception("Location not available. Enable GPS.");

      final res = await ref.read(alertsRepositoryProvider).sendSos(pos.latitude, pos.longitude);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _logout() async {
    await ref.read(authStateProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  String _stripHtml(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }

  void _showPlaceDetails({
    required String name,
    required String type,
    required String description,
    required double lat,
    required double lng,
    String? severity,
  }) {
    final pos = ref.read(locationProvider);
    double? distanceInMeters;
    if (pos != null) {
      distanceInMeters = Geolocator.distanceBetween(
        pos.latitude, pos.longitude, lat, lng,
      );
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(type, style: GoogleFonts.inter(color: Colors.blue.shade700, fontSize: 12)),
                  ),
                  if (severity != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(severity, style: GoogleFonts.inter(color: Colors.red.shade700, fontSize: 12)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Text(description.isEmpty ? 'No description available.' : description, style: GoogleFonts.inter(color: Colors.grey.shade700)),
              const SizedBox(height: 16),
              if (distanceInMeters != null)
                Text('Distance: ${(distanceInMeters / 1000).toStringAsFixed(2)} km away', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(mapDestinationProvider.notifier).setDestination({
                      'latitude': lat,
                      'longitude': lng,
                    });
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B3674),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final pos = ref.watch(locationProvider);
    final riskStatus = ref.watch(riskStatusProvider);
    final destination = ref.watch(mapDestinationProvider);
    final placesAsync = ref.watch(placesProvider);
    final dangerZonesAsync = ref.watch(dangerZonesProvider);

    ref.listen<Map<String, dynamic>?>(mapDestinationProvider, (previous, next) {
      if (next != null && next['error'] != null && previous?['error'] != next['error']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next['error']), backgroundColor: Colors.red),
        );
      }
    });

    Set<Marker> markers = {};
    Set<Polyline> polylines = {};
    Set<Circle> circles = {};
    
    // Add Danger Zones
    dangerZonesAsync.whenData((dangerZones) {
      for (var zone in dangerZones) {
        circles.add(Circle(
          circleId: CircleId('danger_${zone.id}'),
          center: LatLng(zone.latitude, zone.longitude),
          radius: zone.radius.toDouble(),
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          strokeWidth: 2,
          consumeTapEvents: true,
          onTap: () => _showPlaceDetails(
            name: zone.name,
            type: 'Danger Zone - ${zone.riskType}',
            description: zone.additionalDetails,
            lat: zone.latitude,
            lng: zone.longitude,
            severity: zone.severity,
          ),
        ));
      }
    });

    // Add Places
    placesAsync.whenData((places) {
      for (var place in places) {
        BitmapDescriptor icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
        if (place.type.toLowerCase().contains('hospital')) {
          icon = _hospitalIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        } else if (place.type.toLowerCase().contains('police')) {
          icon = _policeIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
        } else if (place.type.toLowerCase().contains('help')) {
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
        }

        markers.add(Marker(
          markerId: MarkerId('place_${place.id}'),
          position: LatLng(place.latitude, place.longitude),
          icon: icon,
          onTap: () => _showPlaceDetails(
            name: place.name,
            type: place.type,
            description: place.description,
            lat: place.latitude,
            lng: place.longitude,
          ),
        ));
      }
    });
    
    if (pos != null) {
      markers.add(Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(pos.latitude, pos.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
      
      if (destination != null) {
        LatLng destLatLng = LatLng(
          double.tryParse(destination['latitude'].toString()) ?? 0.0,
          double.tryParse(destination['longitude'].toString()) ?? 0.0
        );

        if (destLatLng.latitude != 0.0 && destLatLng.longitude != 0.0) {
          markers.add(Marker(
            markerId: const MarkerId('destination'),
            position: destLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ));
        }
        
        if (destination['error'] == null && destLatLng.latitude != 0.0) {
          List<LatLng> polylinePointsList = [
            LatLng(pos.latitude, pos.longitude),
            destLatLng,
          ];
          
          if (destination['routePoints'] != null) {
            polylinePointsList = List<LatLng>.from(destination['routePoints']);
          }
          
          polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: polylinePointsList,
            color: const Color(0xFF2B3674),
            width: 4,
          ));

          if (_mapController != null) {
            double minLat = min(pos.latitude, destLatLng.latitude);
            double maxLat = max(pos.latitude, destLatLng.latitude);
            double minLng = min(pos.longitude, destLatLng.longitude);
            double maxLng = max(pos.longitude, destLatLng.longitude);
            
            LatLngBounds bounds = LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            );

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
            });
          }
        }
      } else {
        if (_mapController != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 14));
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      drawer: _buildSidebar(user?.username),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🏠 Dashboard Overview', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Welcome, ${user?.username ?? 'Tourist'}  |  Smart Tourist Safety System', 
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF555555))
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Color(0xFFE74C3C), size: 18),
              label: Text('Logout', style: GoogleFonts.inter(color: const Color(0xFFE74C3C), fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0x1AE74C3C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Map Container
          Container(
            height: 250,
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E7EF)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (pos != null) {
                        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 14));
                      }
                    },
                    initialCameraPosition: CameraPosition(
                      target: _initialCenter,
                      zoom: 13,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: markers,
                    polylines: polylines,
                    circles: circles,
                  ),
                  if (destination != null && destination['isLoading'] == true)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  if (destination != null && destination['isLoading'] != true) ...[
                    Positioned(
                      top: 10,
                      right: 10,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(mapDestinationProvider.notifier).setDestination(null);
                        },
                        icon: const Icon(Icons.close, size: 16),
                        label: Text('Clear Route', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFE74C3C),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (destination['error'] != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  destination['error'],
                                  style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              )
                            else ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Distance', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                                  Text(
                                    destination['distanceText'] != null ? '${destination['distanceText']}' : (destination['distance'] != null ? '${destination['distance'].toStringAsFixed(2)} km' : 'Calculating...'),
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Est. Time', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                                  Text(
                                    destination['durationText'] != null ? '${destination['durationText']}' : (destination['duration'] != null ? '${destination['duration']} min' : 'Calculating...'),
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  if (destination != null && destination['isLoading'] != true && destination['error'] == null && destination['steps'] != null)
                    Positioned(
                      top: 50,
                      right: 10,
                      bottom: 80, // Leave room for the bottom panel
                      width: 280,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Directions',
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const Divider(),
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: (destination['steps'] as List).length,
                                itemBuilder: (context, index) {
                                  final step = destination['steps'][index];
                                  final instruction = _stripHtml(step['html_instructions'] ?? '');
                                  final distance = step['distance']['text'] ?? '';
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.turn_right, size: 16, color: Color(0xFF2B3674)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            instruction,
                                            style: GoogleFonts.inter(fontSize: 11, color: Colors.black87),
                                          ),
                                        ),
                                        Text(
                                          distance,
                                          style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (pos == null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF39C12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('🔄 Waiting for GPS...', style: GoogleFonts.inter(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Cards Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: constraints.maxWidth > 500 ? 1.5 : 2.0,
                    children: [
                      // Risk Level
                      _buildInfoCard(
                        title: '⚠️ Live Risk Level',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (riskStatus == null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9C4), // Yellow-ish loading
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Loading...', style: GoogleFonts.inter(color: const Color(0xFFF57F17), fontWeight: FontWeight.w600, fontSize: 13)),
                              )
                            else if (riskStatus['inside'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE), // Light Red
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(riskStatus['severity'] ?? 'Danger', style: GoogleFonts.inter(color: const Color(0xFFE53935), fontWeight: FontWeight.w600, fontSize: 13)),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9), // Light Green
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Safe', style: GoogleFonts.inter(color: const Color(0xFF4CAF50), fontWeight: FontWeight.w600, fontSize: 13)),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              riskStatus == null 
                                ? 'Analysing nearby zones...'
                                : (riskStatus['inside'] == true ? (riskStatus['message'] ?? 'You are in a Danger Zone!') : 'You are in a safe area.'),
                              style: GoogleFonts.inter(color: const Color(0xFF777777), fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // Danger Zones
                      _buildInfoCard(
                        title: '🚨 Nearby Danger Zones',
                        child: Text('Tap to view map and zones...', style: GoogleFonts.inter(color: const Color(0xFF999999), fontSize: 13)),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DangerZonesScreen())),
                      ),

                      // Help Centers
                      _buildInfoCard(
                        title: '🏥 Nearby Help Centers',
                        child: Text('Tap to view hospitals and police...', style: GoogleFonts.inter(color: const Color(0xFF999999), fontSize: 13)),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlacesScreen())),
                      ),

                      // SOS
                      _buildInfoCard(
                        title: '🆘 Emergency SOS',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Send your location instantly.', style: GoogleFonts.inter(color: const Color(0xFF555555), fontSize: 12)),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              height: 35, // Give it a fixed compact height
                              child: ElevatedButton(
                                onPressed: _sendSOS,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE74C3C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: EdgeInsets.zero, // reduce padding
                                ),
                                child: Text('SEND SOS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebar(String? username) {
    return Drawer(
      backgroundColor: const Color(0xFF0D1B2A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0x40000000),
              border: Border(bottom: BorderSide(color: Color(0x14FFFFFF))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🛡️ Tourist Panel', style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Smart Safety System', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          _buildNavSection('Overview'),
          _buildNavItem('🏠 Dashboard', true, () { Navigator.pop(context); }),
          _buildNavItem('📊 Risk Level', false, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RiskLevelScreen()));
          }),
          
          _buildNavSection('Alerts & Safety'),
          _buildNavItem('🚨 Danger Zones', false, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DangerZonesScreen()));
          }),
          _buildNavItem('🏥 Help Centers', false, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PlacesScreen()));
          }),
          _buildNavItem('🆘 Emergency SOS', false, () {
            Navigator.pop(context);
            _sendSOS();
          }),

          _buildNavSection('My Account'),
          _buildNavItem('🔔 Notifications', false, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
          }),
          _buildNavItem('👤 Profile', false, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }),
          
          const Divider(color: Color(0x14FFFFFF), height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: InkWell(
              onTap: _logout,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x2EE74C3C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text('🚪 ', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text('Logout', style: GoogleFonts.inter(color: const Color(0xFFFF7675), fontSize: 13.5, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 20, bottom: 5),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildNavItem(String title, bool isActive, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2ECC71) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 13.5,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
