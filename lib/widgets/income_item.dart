import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../helpers/helper.dart';
import '../providers/category.dart';
import '../providers/categories.dart';
import '../providers/metadata.dart';

class IncomeItem extends StatelessWidget {
  final Category income;

  IncomeItem(this.income);

  _onDeleteIncome(ctx, Category income) async {
    try {
      bool isDeleted = await Provider.of<Categories>(ctx, listen: false)
          .deleteCategory(income);

      if (isDeleted) {
        final snackBar = SnackBar(
            content: Text(AppLocalizations.of(ctx)!.msgRemoveIncomeSuccess));
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
        Navigator.of(ctx).pop(true);
      } else {
        final snackBar = SnackBar(
            content: Text(AppLocalizations.of(ctx)!.msgRemoveIncomeFailed));
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
        Navigator.of(ctx).pop(false);
      }
    } catch (error) {
      Navigator.of(ctx).pop(false);
      Helper.showPopup(
          ctx, error, AppLocalizations.of(ctx)!.msgRemoveIncomeFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
//    print(totalSpent);
    var i18n = AppLocalizations.of(context)!;
    return Card(
      elevation: 6,
      margin: EdgeInsets.all(10),
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
                        onPressed: () => _onDeleteIncome(context, income),
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
            child: ListTile(
              title: Text(
                income.description,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, income.volume)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: Icon(
                income.iconData,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
