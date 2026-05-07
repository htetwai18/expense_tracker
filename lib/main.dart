import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/colors.dart';
import 'core/enums.dart';
import 'data_layer/models/expense_category.dart';
import 'data_layer/models/expense_transaction.dart';
import 'persistence_layer/hive_constants.dart';
import 'core/string_collection.dart';
import 'presentation_layer/app/provider.dart';
import 'presentation_layer/splash/screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionToneAdapter());
  Hive.registerAdapter(ExpenseCategoryAdapter());
  Hive.registerAdapter(ExpenseTransactionAdapter());
  await Hive.openBox<ExpenseCategory>(BOX_NAME_EXPENSE_CATEGORY);
  await Hive.openBox<ExpenseTransaction>(BOX_NAME_EXPENSE_TRANSACTION);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          scaffoldBackgroundColor: AppColors.scaffold,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
