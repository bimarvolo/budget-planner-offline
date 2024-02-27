import 'package:flutter/material.dart';
import 'package:money_budget_frontend_offile/providers/user_metadata.dart';
import '../hive/metadata_storage.dart';
import '../providers/categories.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_constant.dart';
import '../providers/budget.dart';
import '../providers/transaction.dart';
import './add_budget_screen.dart';

class AllBudgets extends StatefulWidget {
  static const routeName = '/budget-all';

  @override
  _AllBudgetsState createState() => _AllBudgetsState();
}

class _AllBudgetsState extends State<AllBudgets> {
  /// delete a budget
  Future<bool> _onDeleteBudget(
      BuildContext ctx, Budget budget, int budgetIndex) async {
    String messageText = AppLocalizations.of(ctx)!.msgDeleteBudgetSuccess;
    var box = Hive.box<Budget>('budgets');
    var transBox = Hive.box<Transaction>('transactions');
    var budget = box.getAt(budgetIndex);
    if (budget != null && budget.categories.isNotEmpty) {
      for (var category in budget.categories) {
        var transactions = transBox.values
            .where((element) => element.categoryId == category.id)
            .toList();
        var keysToDelete = transactions.map((e) => e.categoryId).toList();
        transBox.deleteAll(keysToDelete);
      }
    }

    // before delete, find current budget index
    var currentBudgetIndex = MetadataStorage.getMetadata()?.currentBudget;
    var currentBudget = box.getAt(currentBudgetIndex!);
    var savedCurrentBudgetId;
    if (currentBudget != null) {
      // if current budget is the last one, reset to the first one
      savedCurrentBudgetId = currentBudget.id;
    }

    box.deleteAt(budgetIndex);

    // incase delete current budget
    if (budgetIndex == MetadataStorage.getMetadata()?.currentBudget) {
      // reset curent budget to first index if exist
      if (box.values.length > 0) {
        _onBudgetClicked(context, box.getAt(0)!, 0);
      } else
      // reset curent budget to -1 if no budget exist
      {
        MetadataStorage.storeCurrentBudget(-1);
        Provider.of<Categories>(context, listen: false)
            .setItems([], notify: true);
      }
    } else {
      // incase delete non-current budget
      if (box.values.length > 0) {
        // get index of current budget and set it back
        for (var i = 0; i < box.values.length; i++) {
          if (box.getAt(i)!.id == savedCurrentBudgetId) {
            MetadataStorage.storeCurrentBudget(i);
            Provider.of<Categories>(context, listen: false)
                .setItems(box.getAt(i)!.categories, notify: true);
            break;
          }
        }
      } else
      // reset curent budget to -1 if no budget exist
      {
        MetadataStorage.storeCurrentBudget(-1);
        Provider.of<Categories>(context, listen: false)
            .setItems([], notify: true);
      }
    }

    final snackBar = SnackBar(
      content: Text(messageText),
      duration: Duration(seconds: 1)
    );
    ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
    return true;
  }

  void _onBudgetClicked(
      BuildContext ctx, Budget budget, int budgetIndex) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(AppConst.CURRENT_PAGE_KEY);

    MetadataStorage.storeCurrentBudget(budgetIndex);
    Provider.of<Categories>(context, listen: false)
        .setItems(budget.categories, notify: true);
  }

  @override
  Widget build(BuildContext context) {
    var i18n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      height: 800,
      child: ValueListenableBuilder(
          valueListenable: Hive.box<Budget>('budgets').listenable(),
          builder: (context, Box<Budget> budgetBox, __) {
            var size = budgetBox.values.length;
            final budgets = budgetBox.values;
            return size == 0
                ? Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.only(top: 30),
                    child: Column(children: [
                      Text(i18n.youDoNotHaveBudgets),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        child: Text(i18n.createFirstBudget),
                        onPressed: () => {
                          Navigator.of(context).pushNamed(AddBudget.routeName)
                        },
                      )
                    ]))
                : ValueListenableBuilder(
                    valueListenable: Hive.box('metadata').listenable(),
                    builder: (context, Box metadataBox, __) {
                      var meta = metadataBox.get('metadata');
                      var metadata = meta as UserMetadata;
                      return Container(
                        child: ListView.builder(
                          itemCount: size,
                          itemBuilder: (ctx, index) => Padding(
                            padding: const EdgeInsets.only(
                                top: 5.0, left: 10, right: 10),
                            child: Dismissible(
                                key: ValueKey(budgets.elementAt(index).id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss:
                                    (DismissDirection direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(i18n.confirm),
                                        content: Text(i18n
                                            .areYouSureYouWishToDeleteThisItem),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _onDeleteBudget(
                                                    context,
                                                    budgets.elementAt(index),
                                                    index);
                                              },
                                              child: Text(i18n.delete)),
                                          // TextButton(
                                          //   onPressed: () =>
                                          //       Navigator.pop(context, false),
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
                                  padding: EdgeInsets.only(right: 15),
                                ),
                                child: GestureDetector(
                                  onTap: () => _onBudgetClicked(
                                      context, budgets.elementAt(index), index),
                                  child: Card(
                                    color: index == (metadata.currentBudget)
                                        ? Colors.amber[600]
                                        : null,
                                    child: Container(
                                        width: double.infinity,
                                        child: ListTile(
                                          title: Text(budgets
                                              .elementAt(index)
                                              .titleDisplay),
                                          leading: Icon(
                                              Icons.account_balance_wallet),
                                          trailing:
                                              index == metadata.currentBudget
                                                  ? Icon(
                                                      Icons.star,
                                                      color: Colors.amber[100],
                                                    )
                                                  : null,
                                        )),
                                  ),
                                )),
                          ),
                        ),
                      );
                    });
          }),
    );
  }
}
