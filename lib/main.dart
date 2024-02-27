import 'package:flutter/material.dart';
import 'package:money_budget_frontend_offile/providers/user_metadata.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import './providers/budgets.dart';
import './providers/transactions.dart';
import './providers/categories.dart';

import './screens/overview_screen.dart';
import './screens/all_budgets_screen.dart';
import './screens/add_category_screen.dart';
import './screens/add_expensive_screen.dart';
import './screens/edit_expensive_screen.dart';
import './screens/list_transactions_screen.dart';
import './screens/add_budget_screen.dart';
import 'hive/metadata_storage.dart';
import 'providers/transaction.dart';
import 'providers/category.dart';
import 'providers/budget.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(UserMetadataAdapter());

  await Hive.openBox('metadata');
  await Hive.openBox<Budget>('budgets');
  await Hive.openBox<Transaction>('transactions');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('metadata').listenable(),
      builder: (context, box, widget) {
        var metadata = MetadataStorage.getMetadata();
        if (metadata == null) {
          MetadataStorage.initMetadata();
          metadata = MetadataStorage.getMetadata()!;
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider<Budgets>(
              create: (BuildContext context) => Budgets([]),
            ),
            ChangeNotifierProvider<Categories>(
              create: (BuildContext context) => Categories([]),
            ),
            ChangeNotifierProvider<Transactions>(
              create: (BuildContext context) => Transactions([]),
            ),
          ],
          child: MaterialApp(
            title: 'Money budgets',
            localizationsDelegates: [
              AppLocalizations.delegate, // Add this line
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en', ''),
              Locale('vi', ''),
              Locale('fr', ''),
              Locale('es', ''),
              Locale('de', ''),
              Locale('pt', ''),
            ],
            locale: Locale(metadata.lang, ''),
            themeMode: metadata.theme == 'DART'
                ? ThemeMode.dark
                : metadata.theme == 'LIGHT'
                    ? ThemeMode.light
                    : null,
            theme: ThemeData(
              primarySwatch: Colors.cyan,
              fontFamily: 'Lato',
            ),
            darkTheme: ThemeData.dark(), // Provide dark theme
            home: OverviewScreen(),
            routes: {
              AddBudget.routeName: (_) => AddBudget(),
              AddCategory.routeName: (_) => AddCategory(),
              AllBudgets.routeName: (_) => AllBudgets(),
            },
            onGenerateRoute: (RouteSettings settings) {
              Map<String, String>? arg =
                  settings.arguments as Map<String, String>?;
              String categoryId = arg!['id']!;
              String transactionId = arg['id']!;

              var routes = <String, WidgetBuilder>{
                OverviewScreen.routeName: (_) => OverviewScreen(),
                AddExpensive.routeName: (_) => AddExpensive(categoryId),
                EditExpensive.routeName: (_) => EditExpensive(transactionId),
                ListTransactions.routeName: (_) => ListTransactions(categoryId),
              };
              WidgetBuilder builder = routes[settings.name]!;
              return MaterialPageRoute(builder: (ctx) => builder(ctx));
            },
          ),
        );
      },
    );
  }
}
