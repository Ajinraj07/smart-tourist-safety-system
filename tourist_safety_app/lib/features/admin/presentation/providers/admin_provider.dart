import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/admin_repository.dart';

final adminDioClientProvider = Provider<DioClient>((ref) => DioClient());

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(adminDioClientProvider));
});

final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchDashboardStats();
});

final liveTouristsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchLiveTourists();
});

final liveSosProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchLiveSos();
});

final allSosProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchAllSos();
});
