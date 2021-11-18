import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
      bool isDeleted = await Provider.of<Categories>(ctx, listen: false).deleteCategory(cate.id);

      if(isDeleted) {
        final snackBar = SnackBar(content: Text(AppLocalizations
            .of(ctx)
            .msgRemoveCategorySuccess));
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
        Navigator.of(ctx).pop(true);
      } else {
        final snackBar = SnackBar(content: Text(AppLocalizations
            .of(ctx)
            .msgRemoveCategoryFailed));
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
        Navigator.of(ctx).pop(false);
      }

    } catch(e) {
      String message = AppLocalizations.of(ctx).msgCreateBudgetFailed;
      if(e.osError.errorCode == 7)
        message = AppLocalizations.of(ctx).youAreOffline;

      final snackBar = SnackBar(content: Text(message));
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
      Navigator.of(ctx).pop(false);
    }

  }

  @override
  Widget build(BuildContext context) {
    double totalSpent = category.totalSpent == null ? 0.0 : category.totalSpent;
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
                  title: Text(AppLocalizations.of(context).confirm),
                  content: Text(AppLocalizations.of(context).areYouSureYouWishToDeleteThisItem),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => onDeleteCate(context, category),
                        child: Text(AppLocalizations.of(context).delete)
                    ),
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                  ],
                );
              },
            );
          },
          background: Container(
            color: Theme.of(context).errorColor,
            child: Icon(Icons.delete, color: Colors.white, size: 35,),
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
                      if(category.iconData != null)
                        Icon(category.iconData, color: Theme.of(context).accentColor),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                            category.description,
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
                          AppLocalizations.of(context).budgetSpent,
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          category.totalSpent == null
                              ? Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, 0)
                              : Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, category.totalSpent),
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context).budgetPlanned,
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, category.volume),
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
