import 'package:hive_flutter/hive_flutter.dart';

import '../../data_layer/models/expense_category.dart';
import '../hive_constants.dart';

class ExpenseCategoryDao {
  ExpenseCategoryDao._internal();

  static final ExpenseCategoryDao _singleton = ExpenseCategoryDao._internal();

  factory ExpenseCategoryDao() => _singleton;

  Future<void> saveCategory(ExpenseCategory category) {
    return getCategoryBox().put(category.id, category);
  }

  Future<void> saveCategories(List<ExpenseCategory> categories) {
    final categoryMap = {
      for (final category in categories) category.id: category,
    };
    return getCategoryBox().putAll(categoryMap);
  }

  Future<void> deleteCategory(String id) {
    return getCategoryBox().delete(id);
  }

  List<ExpenseCategory> getAllCategories() {
    return getCategoryBox().values.toList();
  }

  Stream<BoxEvent> getAllCategoryEventStream() {
    return getCategoryBox().watch();
  }

  Stream<List<ExpenseCategory>> getAllCategoriesStream() {
    return Stream.value(getAllCategories());
  }

  Box<ExpenseCategory> getCategoryBox() {
    return Hive.box<ExpenseCategory>(BOX_NAME_EXPENSE_CATEGORY);
  }
}
