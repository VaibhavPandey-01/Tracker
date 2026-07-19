import '../models/category.dart';

abstract class ICategoryRepository {
  List<Category> getAll();
  void add(Category category);
  void update(Category category);
  void delete(String id);
}
