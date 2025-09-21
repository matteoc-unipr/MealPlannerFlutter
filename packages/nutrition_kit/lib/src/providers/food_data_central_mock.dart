import '../data/seed_repository.dart';
import 'seeded_provider.dart';

/// Mock provider that mimics USDA FoodData Central responses.
class FoodDataCentralMockProvider extends SeededMockProvider {
  FoodDataCentralMockProvider({SeedFoodRepository? repository})
      : super(
          repository: repository,
          barcodeToFoodId: const {
            '078742300007': '22222222-2222-2222-2222-222222222222',
            '041268000684': '55555555-5555-5555-5555-555555555555',
          },
        );
}
