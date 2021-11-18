
import 'package:money_budget_frontend/app_constant.dart';
import 'package:money_budget_frontend/providers/metadata.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../screens/add_category_screen.dart';
import '../screens/all_budgets_screen.dart';

import '../providers/categories.dart';
import '../providers/budget.dart';
import '../providers/budgets.dart';
import '../providers/category.dart';

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
  Budget budget;
  bool _isLoading = true;
  int _currentTab = 3;

  void _onItemTapped(int tab) {

    setState(() {
      _currentTab = tab;
    });
    _setPrefCurrentPage(tab);
  }

  @override
  void initState() {
    _bindCurrentPage();
    super.initState();
  }

  void _bindCurrentPage() async {
    final prefs = await SharedPreferences.getInstance();
    var page = prefs.getString(AppConst.CURRENT_PAGE_KEY);
    if(page != null && int.tryParse(page) != null) {
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
  
  _setPrefCurrentPage(int p) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConst.CURRENT_PAGE_KEY, p.toString());
  }

  void _showAddCateScreen(BuildContext context, budget) {

    if(budget == null) {
      final snackBar = SnackBar(content: Text(AppLocalizations.of(context).msgShouldCreateFirstBudget));
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
    var metaData = Provider.of<Metadata>(context, listen: true);

    var budget = Provider.of<Budgets>(context, listen: false).findById(metaData.currentBudget);
    var budgetsAppbar = AppBar(
      title: Text(AppLocalizations.of(context).allBudgets),
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          color: Theme.of(context).accentColor,
          // iconSize: 40,
          onPressed: () => {
            Navigator.of(context).pushNamed(AddBudget.routeName),
          },
        ),
      ],
    );

    if(Provider.of<Categories>(context, listen: false).items.length == 0) {
      // this case is when user first login.
      Future.delayed(const Duration(milliseconds: 500), () {
        Budget budget = Provider.of<Budgets>(context, listen: false)
            .findById(metaData.currentBudget);
        Provider.of<Categories>(context, listen: false)
            .setItems(budget.categories);
      });

    }

    var budgetsAppbarTab2 = AppBar(
      title: Text(budget != null ? budget.titleDisplay : AppLocalizations.of(context).budgetPlaner,),
      actions: [
        if (metaData.currentBudget != null)
          PopupMenuButton<bool>(
            onSelected: (bool x) => {_showAddCateScreen(context, budget)},
            itemBuilder: (BuildContext
            context) =>
            <PopupMenuEntry<bool>>[
              PopupMenuItem<bool>(
                value: true,
                child: Text(AppLocalizations.of(context).addCategory),
              ),
            ],
          )
      ],
    );

    return Scaffold(
      appBar: (_currentTab == 2)
          ? budgetsAppbar
          : (_currentTab == 1)
              ? budgetsAppbarTab2
              : AppBar(
                  title: Text(budget != null ? budget.titleDisplay : AppLocalizations.of(context).budgetPlaner,),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: AppLocalizations.of(context).report,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            // icon: Icon(Icons.price_check),
            label: AppLocalizations.of(context).expense,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: AppLocalizations.of(context).budget,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box_outlined),
            label: AppLocalizations.of(context).account,
          ),
        ],
        currentIndex: _currentTab,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.amber,
        onTap: (i) => {_onItemTapped(i),
        },
      ),
      body: _isLoading ? null :
        (_currentTab == 0) ? Report() :
        (_currentTab == 2) ? AllBudgets() :
        (_currentTab == 3) ? Account() : Expense(),

    );
  }
}
