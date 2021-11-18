import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import './providers/metadata.dart';
import './providers/auth.dart';
import './providers/budgets.dart';
import './providers/transactions.dart';
import './providers/categories.dart';

import './screens/overview_screen.dart';
import './screens/auth_screen.dart';
import './screens/all_budgets_screen.dart';
import './screens/add_category_screen.dart';
import './screens/add_expensive_screen.dart';
import './screens/edit_expensive_screen.dart';
import './screens/list_transactions_screen.dart';
import './screens/add_budget_screen.dart';
import './widgets/jumping_dots.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),

        ChangeNotifierProxyProvider<Auth, Metadata>(
          create: (BuildContext context) => Metadata(),
          update: (BuildContext context, Auth auth, Metadata meta) {
            Metadata metadata = auth.metadata;
            if(metadata != null) {
              meta.syncMetadata(metadata.language, metadata.currency, metadata.currentBudget, metadata.themeMode);
            }
            if(auth.isAuth)
              meta.setAuth(auth.userId, auth.token);
            return meta;
            },
        ),
        ChangeNotifierProxyProvider<Auth, Budgets>(
          create: (BuildContext context) => Budgets(Provider.of<Auth>(context, listen: false).token, Provider.of<Auth>(context, listen: false).userId, []),
          update: (BuildContext context, Auth auth, Budgets bud) => Budgets(auth.token, auth.userId, bud.items),
        ),
        ChangeNotifierProxyProvider<Auth, Categories>(
          create: (BuildContext context) => Categories(Provider.of<Auth>(context, listen: false).token, Provider.of<Auth>(context, listen: false).userId, []),
          update: (BuildContext context, Auth auth, Categories cate) => Categories(auth.token, auth.userId, cate.items),
        ),
        ChangeNotifierProxyProvider<Auth, Transactions>(
          create: (BuildContext context) => Transactions(Provider.of<Auth>(context, listen: false).token, Provider.of<Auth>(context, listen: false).userId,[] ),
          update: (BuildContext context, Auth auth, Transactions ex) => Transactions(auth.token, auth.userId, ex.items),
        ),

      ],
      child: Consumer2<Auth, Metadata>(
        builder: (ctx, auth, metadata, _) => MaterialApp(
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
          locale: metadata.language != null ? Locale(metadata.language, '') : null,
          themeMode: metadata.themeMode == 'DART' ? ThemeMode.dark : metadata.themeMode == 'LIGHT' ? ThemeMode.light : null,
          theme: ThemeData(
            primarySwatch: Colors.cyan,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          darkTheme: ThemeData.dark(

          ), // Provide dark theme
          home: auth.isAuth
              ?
          Consumer<Budgets>(
              builder: (ctxB, budgets, __) {
                return FutureBuilder(
                  future: budgets.fetchAndSetBudgets(),
                  builder: (ctxB, AsyncSnapshot<bool> snapshot) {
                    return
                      snapshot.connectionState ==
                          ConnectionState.waiting && budgets.items.length == 0
                          ? JumpingDots()
                      // : OnBoardingPage(),
                          : OverviewScreen();
                  }
                );
              },
          )
              : FutureBuilder(
            future: auth.tryAutoLogin(),
            builder: (ctx, authResultSnapshot) {
              print('authResultSnapshot.connectionState ${authResultSnapshot.connectionState}');
              if (authResultSnapshot.connectionState ==
                  ConnectionState.waiting ) return JumpingDots();
              return AuthScreen();
            }
          ),
          routes: {
            AddBudget.routeName: (_) => AddBudget(),
            AddCategory.routeName: (_) => AddCategory(),
            AllBudgets.routeName: (_) => AllBudgets(),
          },
          onGenerateRoute: (RouteSettings settings) {
            Map<String,String> arg = settings.arguments;
            String categoryId = arg['id'];
            String transactionId = arg['id'];

            var routes = <String, WidgetBuilder>{
              OverviewScreen.routeName: (_) => OverviewScreen(),
              AddExpensive.routeName: (_) => AddExpensive(categoryId),
              EditExpensive.routeName: (_) => EditExpensive(transactionId),
              ListTransactions.routeName: (_) => ListTransactions(categoryId),
            };
            WidgetBuilder builder = routes[settings.name];
            return MaterialPageRoute(builder: (ctx) => builder(ctx));
          },
        ),
      ),
    );
  }
}
