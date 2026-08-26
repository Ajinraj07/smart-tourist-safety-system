import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/danger_zone_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/danger_zone_model.dart';

final dangerZoneRepositoryProvider = Provider<DangerZoneRepository>((ref) {
  return DangerZoneRepository(ref.watch(dioClientProvider));
});

final dangerZonesProvider = FutureProvider<List<DangerZoneModel>>((ref) async {
  final repository = ref.watch(dangerZoneRepositoryProvider);
  return await repository.getDangerZones();
});
