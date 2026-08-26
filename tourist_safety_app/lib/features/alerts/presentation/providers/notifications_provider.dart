import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/alerts_repository.dart';
import '../../../../core/network/dio_client.dart';

final alertsDioClientProvider = Provider<DioClient>((ref) => DioClient());

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepository(ref.watch(alertsDioClientProvider));
});

final notificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(alertsRepositoryProvider);
  return repository.getAlerts();
});
