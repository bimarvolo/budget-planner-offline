import 'package:flutter/material.dart';
import 'package:money_budget_frontend/providers/auth.dart';
import 'package:money_budget_frontend/providers/categories.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_constant.dart';
import '../providers/metadata.dart';
import '../providers/budget.dart';
import '../providers/budgets.dart';
import './add_budget_screen.dart';
import './overview_screen.dart';

class AllBudgets extends StatefulWidget {
  static const routeName = '/budget-all';

  @override
  _AllBudgetsState createState() => _AllBudgetsState();
}

class _AllBudgetsState extends State<AllBudgets> {

  /**
   * delete a budget
   */
  Future<void> _onDeleteBudget(BuildContext ctx, Budget budget, String currentB) async {
    String messageText = AppLocalizations
        .of(ctx)
        .msgDeleteBudgetSuccess;
    bool isDeleted = await Provider.of<Budgets>(ctx, listen: false)
        .deleteBudget(budget.id);
    if (isDeleted) {
      final snackBar = SnackBar(
        content: Text(messageText),
      );
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
      return true;
    } else {
      messageText = AppLocalizations
          .of(ctx)
          .msgDeleteBudgetFailed;

      final snackBar = SnackBar(
        content: Text(messageText),
      );
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);

      if(budget.id == currentB) {
        Provider.of<Metadata>(ctx, listen: false).setCurrentBudget(null);
      }
      return false;
    }
  }

  void _onBudgetClicked(BuildContext ctx, String id) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(AppConst.CURRENT_PAGE_KEY);

    Provider.of<Metadata>(ctx, listen: false).setCurrentBudget(id);

    Budget budget = Provider.of<Budgets>(context, listen: false).findById(id);
    if (budget != null)
        Provider.of<Categories>(context, listen: false)
            .setItems(budget.categories);
  }

  @override
  Widget build(BuildContext context) {
    final budgets = Provider
        .of<Budgets>(context)
        .items;
    var metaData = Provider.of<Metadata>(context, listen: true);

    return Container(
        width: double.infinity,
        height: 800,
        child: budgets.length == 0 // NO budgets
            ? Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(top: 30),
            child: Column(children: [
              Text(AppLocalizations
                  .of(context)
                  .youDoNotHaveBudgets),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: Text(AppLocalizations
                    .of(context)
                    .createFirstBudget),
                onPressed: () =>
                {Navigator.of(context).pushNamed(AddBudget.routeName)},
              )
            ]))
            : ListView.builder(
          itemCount: budgets.length,
          itemBuilder: (ctx, i) =>
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 15, right: 15),
                child: Dismissible(
                    key: ValueKey(budgets[i].id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (DismissDirection direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(AppLocalizations
                                .of(context)
                                .confirm),
                            content: Text(AppLocalizations
                                .of(context)
                                .areYouSureYouWishToDeleteThisItem),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _onDeleteBudget(context, budgets[i], metaData.currentBudget);
                                  },
                                  child: Text(AppLocalizations
                                      .of(context)
                                      .delete)),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: Text(AppLocalizations
                                    .of(context)
                                    .cancel),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    background: Container(
                      color: Theme
                          .of(context)
                          .errorColor,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 35,
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 15),
                    ),
                    child: GestureDetector(
                      onTap: () => _onBudgetClicked(context, budgets[i].id),
                      child: Card(
                        child: Container(
                          width: double.infinity,
                          child:
                          ListTile(
                            title: Text(budgets[i].titleDisplay),
                            trailing: budgets[i].id == metaData.currentBudget ? Icon(Icons.star) : null,
                          )
                        ),
                      ),
                    )),
              ),
        ));
  }
}
