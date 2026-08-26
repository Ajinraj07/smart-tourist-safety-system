import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/admin_provider.dart';
import '../../../danger_zones/presentation/providers/danger_zone_provider.dart';
import '../../../places/presentation/providers/place_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class AdminMonitoringScreen extends ConsumerStatefulWidget {
  const AdminMonitoringScreen({super.key});

  @override
  ConsumerState<AdminMonitoringScreen> createState() => _AdminMonitoringScreenState();
}

class _AdminMonitoringScreenState extends ConsumerState<AdminMonitoringScreen> {
  final MapController _mapController = MapController();
  final LatLng _initialCenter = const LatLng(10.5276, 76.2144);
  String _selectedTab = 'All';

  void _logout() async {
    await ref.read(authStateProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width <= 800;

    return Scaffold(
      backgroundColor: const Color(0xFF1E2130),
      body: SafeArea(
        child: Column(
          children: [
            _buildNavbar(isMobile),
            _buildStatsBar(),
            Expanded(
              child: isMobile
                  ? Column(
                      children: [
                        Expanded(flex: 2, child: _buildMap()),
                        Expanded(flex: 3, child: _buildSidebar(isMobile)),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildMap()),
                        _buildSidebar(isMobile),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar(bool isMobile) {
    return Container(
      height: 60,
      color: const Color(0xFF1A1C29),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 24),
              const SizedBox(width: 5),
              Text('Admin Live Monitoring', style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 18, fontWeight: FontWeight.bold, fontFamily: 'Segoe UI')),
            ],
          ),
          Row(
            children: [
              if (!isMobile) ...[
                const Icon(Icons.person, color: Color(0xFF5E5CE6), size: 16),
                const SizedBox(width: 5),
                const Text('admin', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(width: 20),
              ],
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                label: isMobile ? const SizedBox.shrink() : const Text('Dashboard', style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(backgroundColor: const Color(0xFF2C3140)),
              ),
              const SizedBox(width: 5),
              TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white, size: 16),
                label: isMobile ? const SizedBox.shrink() : const Text('Logout', style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final statsAsync = ref.watch(dashboardStatsProvider);
    
    return Container(
      height: 70,
      color: const Color(0xFF1E2130),
      child: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatItem(Icons.people, Colors.green, stats['total_tourists']?.toString() ?? '0', 'Registered Tourists'),
              _buildStatItem(Icons.warning, Colors.orange, stats['tourists_in_danger']?.toString() ?? '0', 'In Danger Zones'),
              _buildStatItem(Icons.sos, Colors.redAccent, stats['total_sos_today']?.toString() ?? '0', 'SOS Alerts Today'),
              _buildStatItem(Icons.map, Colors.blue, stats['total_danger_zones']?.toString() ?? '0', 'Active Danger Zones', showBorder: false),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String value, String label, {bool showBorder = true}) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        border: showBorder ? const Border(right: BorderSide(color: Color(0xFF2C3140))) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMap() {
    final touristsAsync = ref.watch(liveTouristsProvider);
    final zonesAsync = ref.watch(dangerZonesProvider);
    final placesAsync = ref.watch(placesProvider);

    List<Marker> markers = [];
    List<CircleMarker> circles = [];

    // Render Danger Zones
    if (zonesAsync.hasValue && zonesAsync.value != null) {
      for (var z in zonesAsync.value!) {
        Color zoneColor = Colors.orange;
        if (z.severity.toLowerCase() == 'high') {
          zoneColor = Colors.red;
        } else if (z.severity.toLowerCase() == 'low') {
          zoneColor = Colors.yellow;
        }

        circles.add(
          CircleMarker(
            point: LatLng(z.latitude, z.longitude),
            color: zoneColor.withOpacity(0.3),
            borderColor: zoneColor,
            borderStrokeWidth: 2,
            useRadiusInMeter: true,
            radius: z.radius.toDouble(),
          ),
        );
      }
    }

    // Render Places
    if (placesAsync.hasValue && placesAsync.value != null) {
      for (var p in placesAsync.value!) {
        IconData placeIcon = Icons.local_hospital;
        Color placeColor = Colors.purple;
        String displayType = p.type;
        String searchString = '${p.type} ${p.name}'.toLowerCase();

        if (searchString.contains('police')) {
          placeIcon = Icons.local_police;
          placeColor = Colors.blue;
          displayType = 'Police Station';
        } else if (searchString.contains('help') || searchString.contains('center') || searchString.contains('desk')) {
          placeIcon = Icons.support_agent;
          placeColor = Colors.green;
          displayType = 'Help Center';
        } else if (searchString.contains('hospital') || searchString.contains('clinic')) {
          placeIcon = Icons.local_hospital;
          placeColor = Colors.red;
          displayType = 'Hospital';
        }

        markers.add(
          Marker(
            point: LatLng(p.latitude, p.longitude),
            width: 80,
            height: 50,
            child: Tooltip(
              message: p.name,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey)),
                    child: Icon(placeIcon, color: placeColor, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300)
                    ),
                    child: Text(
                      displayType,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: placeColor),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // Render Tourists
    if (touristsAsync.hasValue && touristsAsync.value != null) {
      for (var t in touristsAsync.value!) {
        if (t['latitude'] != null && t['longitude'] != null) {
          Color markerColor = Colors.blue;
          if (t['status'] == 'sos') markerColor = Colors.red;
          else if (t['status'] == 'danger') markerColor = Colors.orange;

          markers.add(
            Marker(
              point: LatLng(t['latitude'], t['longitude']),
              width: 40,
              height: 40,
              child: Icon(t['status'] == 'sos' ? Icons.warning : Icons.person_pin, color: markerColor, size: 40),
            ),
          );
        }
      }
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _initialCenter,
        initialZoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.tourist_safety_app',
        ),
        CircleLayer(circles: circles),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildSidebar(bool isMobile) {
    final sosAsync = ref.watch(liveSosProvider);
    
    List<dynamic> allSos = sosAsync.value ?? [];
    List<dynamic> filteredSos = allSos.where((s) {
      if (_selectedTab == 'All') return true;
      return s['status']?.toString().toLowerCase() == _selectedTab.toLowerCase();
    }).toList();

    return Container(
      width: isMobile ? double.infinity : 350,
      color: const Color(0xFF1E2130),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Color(0xFF2C3140),
              border: Border(bottom: BorderSide(color: Color(0xFFE53935), width: 2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.sos, color: Colors.redAccent, size: 20),
                    SizedBox(width: 10),
                    Text('Live SOS Alerts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                  child: Text('${allSos.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          
          // Tabs
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTab('All'),
                _buildTab('Pending'),
                _buildTab('Responded'),
                _buildTab('Closed'),
              ],
            ),
          ),
          
          const Divider(color: Color(0xFF2C3140), height: 1),

          // Content
          Expanded(
            child: sosAsync.when(
              data: (sos) {
                if (filteredSos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.check_box, color: Colors.greenAccent, size: 50),
                        ),
                        const SizedBox(height: 15),
                        const Text('No SOS alerts today', style: TextStyle(color: Colors.white54, fontSize: 16)),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: filteredSos.length,
                  itemBuilder: (context, index) {
                    final item = filteredSos[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: const Color(0xFF2C3140), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['tourist_name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(item['time_ago'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text('Status: ${item['status']}', style: TextStyle(color: item['status'] == 'pending' ? Colors.redAccent : Colors.orange, fontSize: 13)),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    bool isSelected = _selectedTab == title;
    return InkWell(
      onTap: () => setState(() => _selectedTab = title),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.redAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? null : Border.all(color: const Color(0xFF2C3140)),
        ),
        child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 12)),
      ),
    );
  }
}
