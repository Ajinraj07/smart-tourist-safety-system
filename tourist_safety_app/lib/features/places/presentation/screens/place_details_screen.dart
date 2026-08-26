import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/place_model.dart';
import '../../../maps/presentation/providers/location_provider.dart';

class PlaceDetailsScreen extends ConsumerWidget {
  final PlaceModel place;

  const PlaceDetailsScreen({super.key, required this.place});

  void _getDirectionsOnDashboard(BuildContext context, WidgetRef ref) {
    ref.read(mapDestinationProvider.notifier).setDestination({
      'latitude': place.latitude,
      'longitude': place.longitude,
    });
    Navigator.of(context).pop(); // Close Details Screen
    Navigator.of(context).pop(); // Close Places Screen
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref.watch(locationProvider);
    
    String distanceStr = "Calculating distance...";
    if (pos != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        place.latitude,
        place.longitude,
      );
      distanceStr = "${(distanceInMeters / 1000).toStringAsFixed(1)} km away";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text(place.name, style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.local_hospital, size: 60, color: Color(0xFF00B074)),
                  const SizedBox(height: 16),
                  Text(place.name, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF2B3674)), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B074).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(place.type, style: GoogleFonts.inter(color: const Color(0xFF00B074), fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Details', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3674))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.location_on, place.address.isNotEmpty ? place.address : 'Address not available'),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.map, distanceStr),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.info_outline, place.description.isNotEmpty ? place.description : 'No description available'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _getDirectionsOnDashboard(context, ref),
                icon: const Icon(Icons.directions, color: Colors.white),
                label: Text('Get Directions (In App)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF2B3674), size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF555555), height: 1.5))),
      ],
    );
  }
}
