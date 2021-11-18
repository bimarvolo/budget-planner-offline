import 'package:flutter/material.dart';
import 'package:money_budget_frontend/helpers/helper.dart';
import 'package:money_budget_frontend/providers/budgets.dart';
import 'package:money_budget_frontend/providers/categories.dart';
import 'package:money_budget_frontend/widgets/category_item.dart';
import 'package:money_budget_frontend/widgets/category_widget.dart';
import 'package:money_budget_frontend/widgets/income_item.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:recase/recase.dart';
import '../providers/metadata.dart';
import '../providers/auth.dart';
import 'add_budget_screen.dart';

class Expense extends StatefulWidget {
  static const routeName = '/account';

  @override
  _ExpenseState createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<Auth>(context, listen: true);
    var metaData = Provider.of<Metadata>(context, listen: true);

    final expensiveCates =
        Provider.of<Categories>(context, listen: true).expensiveCategories;

    final incomes =
        Provider.of<Categories>(context, listen: true).incomeCategories;
    final budgeted = expensiveCates.fold(0, (i, el) {
      return i + el.volume;
    });
    final expenditure = expensiveCates.fold(0, (i, el) {
      return i + el.totalSpent;
    });
    final totalIncomes = incomes.fold(0, (i, el) {
      return i + el.volume;
    });
    final remainingToSpend = budgeted - expenditure;

    return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(children: [
            if (metaData.currentBudget == null)
              Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(top: 20),
                  child: Column(children: [
                    Text(
                      AppLocalizations.of(context).youDoNotHaveBudgets,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      child: Text(AppLocalizations.of(context).createFirstBudget),
                      onPressed: () =>
                          {Navigator.of(context).pushNamed(AddBudget.routeName)},
                    )
                  ])),
            if (metaData.currentBudget != null && expensiveCates.length == 0)
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  AppLocalizations.of(context).useButtonToCreateCategories,
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                ),
              ]),
            if (metaData.currentBudget != null && expensiveCates.length > 0)
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
                                new ReCase(
                                        AppLocalizations.of(context).netIncomes)
                                    .titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, budgeted)}',
                                new ReCase(AppLocalizations.of(context).budgeted)
                                    .titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, remainingToSpend)}',
                                new ReCase(AppLocalizations.of(context)
                                        .remainingToSpend)
                                    .titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, totalIncomes - expenditure)}',
                                new ReCase(AppLocalizations.of(context).saving)
                                    .titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, expenditure)}',
                                new ReCase(
                                        AppLocalizations.of(context).expenditure)
                                    .titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, totalIncomes - budgeted)}',
                                new ReCase(AppLocalizations.of(context)
                                        .provisionalBalance)
                                    .titleCase),
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
                            '${AppLocalizations.of(context).expenditure} ${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, expenditure)}',
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
                            '${AppLocalizations.of(context).incomes} ${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, totalIncomes)}',
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
