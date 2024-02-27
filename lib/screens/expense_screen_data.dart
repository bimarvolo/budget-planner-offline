import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recase/recase.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../helpers/helper.dart';
import '../hive/metadata_storage.dart';
import '../providers/budget.dart';
import '../providers/categories.dart';
import '../providers/category.dart';
import '../widgets/category_item.dart';
import '../widgets/category_widget.dart';
import '../widgets/income_item.dart';

class ExpenseData extends StatefulWidget {
  ExpenseData();

  @override
  _ExpenseState createState() => _ExpenseState();
}

class _ExpenseState extends State<ExpenseData> {
  @override
  Widget build(BuildContext context) {
    var i18n = AppLocalizations.of(context)!;
    var metadata = MetadataStorage.getMetadata()!;
    List<Category> expensiveCates = [];
    List<Category> incomes = [];

    expensiveCates =
        Provider.of<Categories>(context, listen: true).expensiveCategories;

    incomes = Provider.of<Categories>(context, listen: true).incomeCategories;

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
            if (expensiveCates.length == 0 && incomes.length == 0)
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  i18n.useButtonToCreateCategories,
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                ),
              ]),
            if (expensiveCates.length > 0 || incomes.length > 0)
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 0, left: 0, right: 5.0, bottom: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            CateWidget(
                                '${Helper.formatCurrency(metadata.currency, totalIncomes)}',
                                new ReCase(i18n.netIncomes).titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(metadata.currency, budgeted)}',
                                new ReCase(i18n.budgeted).titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(metadata.currency, remainingToSpend)}',
                                new ReCase(i18n.remainingToSpend).titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(metadata.currency, totalIncomes - expenditure)}',
                                new ReCase(i18n.saving).titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(metadata.currency, expenditure)}',
                                new ReCase(i18n.expenditure).titleCase),
                            CateWidget(
                                '${Helper.formatCurrency(metadata.currency, totalIncomes - budgeted)}',
                                new ReCase(i18n.provisionalBalance).titleCase),
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${i18n.expenditure} ${Helper.formatCurrency(metadata.currency, expenditure)}',
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
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${i18n.incomes} ${Helper.formatCurrency(metadata.currency, totalIncomes)}',
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
