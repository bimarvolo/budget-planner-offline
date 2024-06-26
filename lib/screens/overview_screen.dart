import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:money_budget_frontend_offile/providers/categories.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_constant.dart';
import '../hive/metadata_storage.dart';
import '../screens/add_category_screen.dart';
import '../screens/all_budgets_screen.dart';
import '../providers/budget.dart';
import './add_budget_screen.dart';
import './report_screen.dart';
import './account_screen.dart';
import './expense_screen.dart';

class OverviewScreen extends StatefulWidget {
  static const routeName = '/overview';

  OverviewScreen();

  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  Budget? budget;
  bool _isLoading = true;
  int _currentTab = 1;

  void _onItemTapped(int tab) {
    setState(() {
      _currentTab = tab;
    });
    _setPrefCurrentPage(tab);
  }

  @override
  void initState() {
    _bindCurrentPage();
    _bindCurrentBudget();
    print('Overview is initing .... $_currentTab');
    super.initState();
  }

  void _bindCurrentPage() async {
    final prefs = await SharedPreferences.getInstance();
    var page = prefs.getString(AppConst.CURRENT_PAGE_KEY);
    if (page != null && int.tryParse(page) != null) {
      setState(() {
        _currentTab = int.parse(page);
      });
    } else {
      setState(() {
        _currentTab = 1;
      });
    }

    _isLoading = false;
  }

  void _bindCurrentBudget() async {
    var metadata = MetadataStorage.getMetadata();
    if (metadata != null && metadata.currentBudget != -1) {
      var box = Hive.box<Budget>('budgets');
      setState(() {
        budget = box.getAt(metadata.currentBudget);
      });

      Provider.of<Categories>(context, listen: false)
          .setItems(budget!.categories);
    }
  }

  _setPrefCurrentPage(int p) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConst.CURRENT_PAGE_KEY, p.toString());
  }

  void _showAddCateScreen(BuildContext context, budget) {
    if (budget == null) {
      final snackBar = SnackBar(
          content:
              Text(AppLocalizations.of(context)!.msgShouldCreateFirstBudget),
          duration: Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    // Navigator.pushNamed(context, AddCategory.routeName,
    //     arguments: {'budgetId': budget.id, 'budgetName': budget.title});
    Navigator.pushNamed(context, AddCategory.routeName);
  }

  @override
  Widget build(BuildContext context) {
    print('Overview is reloading .... $_currentTab');
    var i18n = AppLocalizations.of(context)!;
    var metadata = MetadataStorage.getMetadata();

    var budget;
    if (metadata != null && metadata.currentBudget != -1) {
      var box = Hive.box<Budget>('budgets');
      if (box.values.isNotEmpty) {
        budget = box.getAt(metadata.currentBudget);
      }
    }
    var budgetsAppbar = AppBar(
      title: Text(i18n.allBudgets),
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          color: Theme.of(context).colorScheme.secondary,
          // iconSize: 40,
          onPressed: () => {
            Navigator.of(context).pushNamed(AddBudget.routeName),
          },
        ),
      ],
    );

    var budgetsAppbarTabAccount = AppBar(
      title: Text(i18n.settings),
    );

    var budgetsAppbarTab2 = AppBar(
      title: Text(
        budget != null ? budget.titleDisplay : i18n.budgetPlaner,
      ),
      actions: [
        if (metadata != null && metadata.currentBudget != -1 && budget != null)
          PopupMenuButton<bool>(
            onSelected: (bool x) => {_showAddCateScreen(context, budget)},
            itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
              PopupMenuItem<bool>(
                value: true,
                child: Text(i18n.addCategory),
              ),
            ],
          )
      ],
    );

    return Scaffold(
      appBar: (_currentTab == 3)
          ? budgetsAppbarTabAccount
          : (_currentTab == 2)
              ? budgetsAppbar
              : (_currentTab == 1)
                  ? budgetsAppbarTab2
                  : AppBar(
                      title: Text(
                        budget != null
                            ? budget.titleDisplay
                            : i18n.budgetPlaner,
                      ),
                    ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: i18n.report,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            // icon: Icon(Icons.price_check),
            label: i18n.expense,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: i18n.budget,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: i18n.settings,
          ),
        ],
        currentIndex: _currentTab,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.amber,
        onTap: (i) => {
          _onItemTapped(i),
        },
      ),
      body: _isLoading
          ? null
          : (_currentTab == 0)
              ? Report()
              : (_currentTab == 2)
                  ? AllBudgets()
                  : (_currentTab == 3)
                      ? Account()
                      : Expense(),
    );
  }
}
