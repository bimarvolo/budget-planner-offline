import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/budget.dart';
import '../providers/category.dart';
import '../helpers/helper.dart';
import '../providers/metadata.dart';
import '../providers/categories.dart';
import '../widgets/spend_bar.dart';
import '../screens/list_transactions_screen.dart';

class CategoryItem extends StatelessWidget {
  final Category category;

  CategoryItem(this.category);

  onDeleteCate(ctx, Category cate) async {
    try {
      Metadata metaData = Provider.of<Metadata>(ctx, listen: false);

      var budget;
      if (metaData.currentBudget != null) {
        var box = Hive.box<Budget>('budgets');
        budget = box.getAt(metaData.currentBudget!);

        List<Category> categories = budget!.categories;
        categories.remove(cate);
        budget!.categories = categories;
        box.put(budget!.id, budget!);

        await Provider.of<Categories>(ctx, listen: false).deleteCategory(cate);
        final snackBar = SnackBar(
            content: Text(AppLocalizations.of(ctx)!.msgRemoveCategorySuccess));
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
        Navigator.of(ctx).pop(true);
      }
    } catch (e) {
      String message = AppLocalizations.of(ctx)!.msgCreateBudgetFailed;

      final snackBar = SnackBar(content: Text(message));
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
      Navigator.of(ctx).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var i18n = AppLocalizations.of(context)!;
    double totalSpent = category.totalSpent;
    return Card(
      elevation: 6,
      margin: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () => {
          Navigator.pushNamed(context, ListTransactions.routeName,
              arguments: {'id': category.id})
        },
        child: Dismissible(
          key: ValueKey(category.id),
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
                        onPressed: () => onDeleteCate(context, category),
                        child: Text(i18n.delete)),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(i18n.cancel),
                    ),
                  ],
                );
              },
            );
          },
          background: Container(
            color: Theme.of(context).errorColor,
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: 35,
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
          ),
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (category.iconData != null)
                        Icon(category.iconData,
                            color: Theme.of(context).accentColor),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(category.description,
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          i18n.budgetSpent,
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          category.totalSpent == null
                              ? Helper.formatCurrency(
                                  Provider.of<Metadata>(context, listen: false)
                                      .currency,
                                  0)
                              : Helper.formatCurrency(
                                  Provider.of<Metadata>(context, listen: false)
                                      .currency,
                                  category.totalSpent),
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          i18n.budgetPlanned,
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          Helper.formatCurrency(
                              Provider.of<Metadata>(context, listen: false)
                                  .currency,
                              category.volume),
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                SpendBar(category.volume, totalSpent / category.volume),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
