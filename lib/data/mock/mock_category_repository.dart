import '../../domain/models/category.dart';
import '../../domain/repositories/i_category_repository.dart';
import 'seed_data.dart';

class MockCategoryRepository implements ICategoryRepository {
  final List<Category> _categories = List.from(seedCategories);

  @override
  List<Category> getAll() => List.unmodifiable(_categories);

  @override
  void add(Category category) => _categories.add(category);

  @override
  void update(Category category) {
    final i = _categories.indexWhere((c) => c.id == category.id);
    if (i != -1) _categories[i] = category;
  }

  @override
  void delete(String id) => _categories.removeWhere((c) => c.id == id);
}
