import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../helpers/helper.dart';
import '../providers/budget.dart';
import '../providers/categories.dart';
import '../providers/category.dart';
import '../widgets/category_item.dart';
import '../widgets/category_widget.dart';
import '../widgets/income_item.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:recase/recase.dart';
import '../providers/metadata.dart';
import 'add_budget_screen.dart';

class Expense extends StatefulWidget {
  static const routeName = '/expense';

  @override
  _ExpenseState createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  @override
  Widget build(BuildContext context) {
    var i18n = AppLocalizations.of(context)!;
    var metaData = Provider.of<Metadata>(context, listen: true);

    var budgetIndex = metaData.currentBudget;
    Box<Budget> budgetBox = Hive.box<Budget>('budgets');
    Budget? curentBudget;

    List<Category> expensiveCates = [];
    List<Category> incomes = [];
    Provider.of<Categories>(context, listen: true).incomeCategories;

    if (budgetIndex != null) {
      curentBudget = budgetBox.getAt(budgetIndex);
      expensiveCates = curentBudget!.categories;
    }

    final budgeted = expensiveCates.fold<double>(0, (i, el) {
      return i + el.volume;
    });
    final expenditure = expensiveCates.fold<double>(0, (i, el) {
      return i + el.totalSpent;
    });
    final totalIncomes = incomes.fold<double>(0, (i, el) {
      return i + el.volume;
    });
    final remainingToSpend = budgeted - expenditure;

    return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(children: [
            if (curentBudget == null)
              Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(top: 20),
                  child: Column(children: [
                    Text(
                      i18n.youDoNotHaveBudgets,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      child: Text(i18n.createFirstBudget),
                      onPressed: () => {
                        Navigator.of(context).pushNamed(AddBudget.routeName)
                      },
                    )
                  ])),
            if (curentBudget != null && expensiveCates.length == 0)
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  i18n.useButtonToCreateCategories,
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                ),
              ]),
            if (curentBudget != null && expensiveCates.length > 0)
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      // child: OverviewItem(),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            CateWidget(
                                '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, totalIncomes)}',
                                new ReCase(i18n.netIncomes).titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, budgeted)}',
                                new ReCase(i18n.budgeted).titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, remainingToSpend)}',
                                new ReCase(i18n.remainingToSpend).titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, totalIncomes - expenditure)}',
                                new ReCase(i18n.saving).titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, expenditure)}',
                                new ReCase(i18n.expenditure).titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, totalIncomes - budgeted)}',
                                new ReCase(i18n.provisionalBalance).titleCase),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${i18n.expenditure} ${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, expenditure)}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    for (var cate in expensiveCates) CategoryItem(cate),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${i18n.incomes} ${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, totalIncomes)}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    for (var cate in incomes) IncomeItem(cate),
                  ])
          ]),
        ));
  }
}
