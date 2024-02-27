import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_budget_frontend_offile/providers/budget.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../helpers/helper.dart';
import '../hive/metadata_storage.dart';
import '../providers/category.dart';
import '../providers/categories.dart';

class IncomeItem extends StatelessWidget {
  final Category income;

  IncomeItem(this.income);

  _onDeleteIncome(ctx, int budgetId, Category income) async {
    try {
      Box<Budget> budgetBox = Hive.box("budgets");
      Budget budget = budgetBox.getAt(budgetId)!;
      budget.categories.removeWhere((element) => element.id == income.id);
      budgetBox.put(budget.id, budget);

      await Provider.of<Categories>(ctx, listen: false).deleteCategory(income);

      final snackBar = SnackBar(
          content: Text(AppLocalizations.of(ctx)!.msgRemoveIncomeSuccess),
          duration: Duration(seconds: 1));
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
      Navigator.of(ctx).pop(true);
    } catch (error) {
      Navigator.of(ctx).pop(false);
      Helper.showPopup(
          ctx, error, AppLocalizations.of(ctx)!.msgRemoveIncomeFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    var metadata = MetadataStorage.getMetadata()!;
    var i18n = AppLocalizations.of(context)!;
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () => {},
        child: Dismissible(
          key: ValueKey(income.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (DismissDirection direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(i18n.confirm),
                  content: Text(i18n.areYouSureYouWishToDeleteThisItem),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => _onDeleteIncome(
                            context, metadata.currentBudget, income),
                        child: Text(i18n.delete)),
                    // TextButton(
                    //   onPressed: () => Navigator.of(context).pop(false),
                    //   child: Text(i18n.cancel),
                    // ),
                  ],
                );
              },
            );
          },
          background: Container(
            color: Theme.of(context).colorScheme.error,
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: 35,
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
          ),
          child: Container(
            child: ListTile(
              title: Text(
                income.description,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${Helper.formatCurrency(metadata.currency, income.volume)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: Icon(
                income.iconData,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
