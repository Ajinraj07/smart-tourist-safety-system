import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/place_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/place_model.dart';

final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return PlaceRepository(ref.watch(dioClientProvider));
});

final placesProvider = FutureProvider<List<PlaceModel>>((ref) async {
  final repository = ref.watch(placeRepositoryProvider);
  return await repository.getPlaces();
});
