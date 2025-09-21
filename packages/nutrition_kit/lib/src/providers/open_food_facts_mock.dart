import '../data/seed_repository.dart';
import 'seeded_provider.dart';

/// Mock implementation that emulates a subset of the Open Food Facts API.

class OpenFoodFactsMockProvider extends SeededMockProvider {
  OpenFoodFactsMockProvider({SeedFoodRepository? repository})
      : super(
          repository: repository,
          barcodeToFoodId: const {
            '8901234567890': '11111111-1111-1111-1111-111111111111',
            '1234567890123': '44444444-4444-4444-4444-444444444444',
          },
        );
}
