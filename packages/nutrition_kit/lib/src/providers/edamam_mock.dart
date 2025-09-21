import '../data/seed_repository.dart';
import 'seeded_provider.dart';

/// Mock implementation that mirrors a subset of the Edamam food database.
class EdamamMockProvider extends SeededMockProvider {
  EdamamMockProvider({SeedFoodRepository? repository})
      : super(
          repository: repository,
          barcodeToFoodId: const {
            '9421902960000': '33333333-3333-3333-3333-333333333333',
            '016000275233': '66666666-6666-6666-6666-666666666666',
          },
        );
}
