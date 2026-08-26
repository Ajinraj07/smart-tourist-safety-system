import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../maps/presentation/providers/location_provider.dart';
import '../providers/notifications_provider.dart';

typedef Coords = ({double lat, double lon});

final nearbyRiskDataProvider = FutureProvider.family<Map<String, dynamic>, Coords>((ref, coords) async {
  final repository = ref.watch(alertsRepositoryProvider);
  return repository.getNearbyData(coords.lat, coords.lon);
});

class RiskLevelScreen extends ConsumerWidget {
  const RiskLevelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref.watch(locationProvider);
    final riskStatus = ref.watch(riskStatusProvider);

    if (pos == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Risk Analysis'), backgroundColor: Colors.white, foregroundColor: Colors.black),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final nearbyDataAsync = ref.watch(nearbyRiskDataProvider((lat: pos.latitude, lon: pos.longitude)));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text('Risk Analysis', style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Status Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Current Live Risk Level', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 12),
                    if (riskStatus == null)
                       const CircularProgressIndicator()
                    else if (riskStatus['inside'] == true)
                      Column(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 64, color: Colors.red[700]),
                          const SizedBox(height: 8),
                          Text(riskStatus['severity'] ?? 'Danger', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red[700])),
                          const SizedBox(height: 8),
                          Text(riskStatus['message'] ?? 'You are in a Danger Zone', style: GoogleFonts.inter(fontSize: 14, color: Colors.black87)),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Icon(Icons.verified_user_rounded, size: 64, color: Colors.green[600]),
                          const SizedBox(height: 8),
                          Text('Safe', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[600])),
                          const SizedBox(height: 8),
                          Text('You are currently in a safe area.', style: GoogleFonts.inter(fontSize: 14, color: Colors.black87)),
                        ],
                      )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Nearby Danger Zones', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3674))),
            const SizedBox(height: 12),
            nearbyDataAsync.when(
              data: (data) {
                final zones = data['zones'] as List<dynamic>? ?? [];
                if (zones.isEmpty) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('No danger zones found within a 5km radius.', style: GoogleFonts.inter(color: Colors.grey), textAlign: TextAlign.center),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: zones.length,
                  itemBuilder: (context, index) {
                    final zone = zones[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFEBEE),
                          child: Icon(Icons.location_on, color: Color(0xFFE53935)),
                        ),
                        title: Text(zone['name'] ?? 'Unknown Zone', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        subtitle: Text('${zone['risk_type']} • ${zone['severity']} Risk', style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
                        trailing: Text('${(zone['distance'] as double).toStringAsFixed(2)} km', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF2B3674))),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading nearby zones: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
