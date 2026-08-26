import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/danger_zone_provider.dart';

class DangerZonesScreen extends ConsumerWidget {
  const DangerZonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(dangerZonesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Danger Zones')),
      body: zonesAsync.when(
        data: (zones) => ListView.builder(
          itemCount: zones.length,
          itemBuilder: (context, index) {
            final zone = zones[index];
            return ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: Text(zone.name),
              subtitle: Text('Severity: ${zone.severity} | Risk: ${zone.riskType}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(err.toString())),
      ),
    );
  }
}
