import 'package:flutter/material.dart';
import '../providers/categories.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_constant.dart';
import '../providers/metadata.dart';
import '../providers/budget.dart';
import '../providers/budgets.dart';
import './add_budget_screen.dart';

class AllBudgets extends StatefulWidget {
  static const routeName = '/budget-all';

  @override
  _AllBudgetsState createState() => _AllBudgetsState();
}

class _AllBudgetsState extends State<AllBudgets> {
  /// delete a budget
  Future<bool> _onDeleteBudget(
      BuildContext ctx, Budget budget, int currentB) async {
    String messageText = AppLocalizations.of(ctx)!.msgDeleteBudgetSuccess;
    var box = Hive.box<Budget>('budgets');
    box.deleteAt(currentB);
    
    final snackBar = SnackBar(
        content: Text(messageText),
      );
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
      return true;
  }

  void _onBudgetClicked(
      BuildContext ctx, Budget budget, int budgetIndex) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(AppConst.CURRENT_PAGE_KEY);

    Provider.of<Metadata>(ctx, listen: false).setCurrentBudget(budgetIndex);

    Provider.of<Categories>(context, listen: false).setItems(budget.categories);

    // Box metaDataBox = Hive.box('metadata');
    // metaDataBox.put('budgetIndex', budgetIndex);
  }

  @override
  Widget build(BuildContext context) {
    // final budgets = Provider.of<Budgets>(context).items;
    var metaData = Provider.of<Metadata>(context, listen: true);
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
                : ListView.builder(
                    itemCount: size,
                    itemBuilder: (ctx, index) => Padding(
                      padding:
                          const EdgeInsets.only(top: 10.0, left: 15, right: 15),
                      child: Dismissible(
                          key: ValueKey(budgets.elementAt(index).id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (DismissDirection direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(i18n.confirm),
                                  content: Text(
                                      i18n.areYouSureYouWishToDeleteThisItem),
                                  actions: <Widget>[
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _onDeleteBudget(context,
                                              budgets.elementAt(index), index);
                                        },
                                        child: Text(i18n.delete)),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
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
                            padding: EdgeInsets.only(right: 15),
                          ),
                          child: GestureDetector(
                            onTap: () => _onBudgetClicked(
                                context, budgets.elementAt(index), index),
                            child: Card(
                              color: budgets.elementAt(index).id ==
                                      metaData.currentBudget
                                  ? Colors.amber[400]
                                  : null,
                              child: Container(
                                  width: double.infinity,
                                  child: ListTile(
                                    title: Text(
                                        budgets.elementAt(index).titleDisplay),
                                    trailing: budgets.elementAt(index).id ==
                                            metaData.currentBudget
                                        ? Icon(
                                            Icons.star,
                                            // color: Colors.amber[200],
                                          )
                                        : null,
                                  )),
                            ),
                          )),
                    ),
                  );
          }),
    );
  }
}
