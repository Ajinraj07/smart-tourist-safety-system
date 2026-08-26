import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/alerts_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepository(ref.watch(dioClientProvider));
});
