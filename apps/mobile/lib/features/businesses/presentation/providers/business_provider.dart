import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/models/business_model.dart';
import '../../data/repositories/business_repository.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  // Using the shared api client
  final secureStorage = SecureStorage();
  final apiClient = ApiClient(secureStorage);
  return BusinessRepository(apiClient);
});

final myBusinessesProvider = FutureProvider<List<BusinessModel>>((ref) async {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getMyBusinesses();
});
