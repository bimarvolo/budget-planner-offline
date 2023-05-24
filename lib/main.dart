import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import './providers/metadata.dart';
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
import './widgets/jumping_dots.dart';
import 'providers/transaction.dart';
import 'providers/category.dart';
import 'providers/budget.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(BudgetAdapter());

  await Hive.openBox('metadata');

  final box = await Hive.openBox<Budget>('budgets');
  // box.clear();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Metadata>(
          create: (BuildContext context) => Metadata(),
        ),
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
      child: Consumer<Metadata>(
        builder: (ctx, metadata, _) => MaterialApp(
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
          ],
          locale:
              metadata.language != null ? Locale(metadata.language!, '') : null,
          themeMode: metadata.themeMode == 'DART'
              ? ThemeMode.dark
              : metadata.themeMode == 'LIGHT'
                  ? ThemeMode.light
                  : null,
          theme: ThemeData(
            primarySwatch: Colors.cyan,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          darkTheme: ThemeData.dark(), // Provide dark theme
          home: FutureBuilder(
              future: Future.wait([
                Hive.openBox<Budget>('budgets'),
                Hive.openBox<Transaction>('transactions')
              ]),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError)
                    return Text(snapshot.error.toString());
                  else {
                    var meta = Provider.of<Metadata>(context, listen: false);
                    if (meta.currency == null) {
                      meta.setCurrency('\$');
                    }

                    return OverviewScreen();
                  }
                } else
                  return Scaffold();
              }),
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
      ),
    );
  }
}
