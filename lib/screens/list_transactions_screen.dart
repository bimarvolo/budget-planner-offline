import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_budget_frontend_offile/hive/metadata_storage.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../helpers/helper.dart';
import '../providers/budget.dart';
import '../providers/transactions.dart';
import '../providers/transaction.dart';
import '../providers/categories.dart';
import '../providers/category.dart';
import '../widgets/spend_bar.dart';
import './add_expensive_screen.dart';
import './edit_expensive_screen.dart';

class ListTransactions extends StatefulWidget {
  static const routeName = '/transaction';

  final String categoryId;

  ListTransactions(this.categoryId);

  @override
  _ListTransactionsState createState() => _ListTransactionsState();
}

class _ListTransactionsState extends State<ListTransactions> {
  @override
  void initState() {
    Provider.of<Transactions>(context, listen: false)
        .fetchAndSetExpensive(widget.categoryId);

    super.initState();
  }

  Future<void> _onTransDelete(ctx, transId, volume, currentBudget) async {
    await Provider.of<Transactions>(context, listen: false)
        .deleteTransaction(transId);

    Box budgetsBox = Hive.box<Budget>('budgets');
    Budget updateBudget = budgetsBox.values.elementAt(currentBudget);
    updateBudget.categories = updateBudget.categories.map((cate) {
      if (cate.id == widget.categoryId) {
        cate.totalSpent -= volume;
      }
      return cate;
    }).toList();

    // Update DB
    budgetsBox.put(updateBudget.id, updateBudget);

    Provider.of<Categories>(context, listen: false).notifyDataChange();

    final snackBar = SnackBar(
        content: Text(AppLocalizations.of(context)!.msgDeleteExpenseSuccess),
        duration: Duration(seconds: 1));
    ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    var metadata = MetadataStorage.getMetadata();
    var i18n = AppLocalizations.of(context)!;
    late Category category;
    List<Category> categories =
        Provider.of<Categories>(context, listen: false).expensiveCategories;
    if (categories.length != 0) {
      category = categories.firstWhere((cate) => cate.id == widget.categoryId);
    }

    List<Transaction> transactions = Provider.of<Transactions>(context).items;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.of(context).pushNamed(AddExpensive.routeName, arguments: {
            'id': widget.categoryId,
          }),
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('${category.description}'),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.add,
        //       color: Theme.of(context).colorScheme.secondary,
        //     ),
        //     // iconSize: 40,
        //     onPressed: () => {
        //       Navigator.of(context)
        //           .pushNamed(AddExpensive.routeName, arguments: {
        //         'id': widget.categoryId,
        //       }),
        //     },
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Text(
                  i18n.youSpent,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  // '${category.totalSpent}',
                  '${Helper.formatCurrency(metadata!.currency, category.totalSpent)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ]),
              Row(children: [
                Text(
                  '${i18n.budget} :',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  '${Helper.formatCurrency(metadata.currency, category.volume)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ]),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          SpendBar(category.volume, category.totalSpent / category.volume),
          SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 200,
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (ctx, i) => Dismissible(
                    key: ValueKey(transactions[i].id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (DismissDirection direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(i18n.confirm),
                            content:
                                Text(i18n.areYouSureYouWishToDeleteThisItem),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => {
                                  _onTransDelete(
                                      context,
                                      transactions[i].id,
                                      transactions[i].volume,
                                      metadata.currentBudget)
                                },
                                child: Text(i18n.delete),
                              ),
                              // TextButton(
                              //   onPressed: () =>
                              //       Navigator.of(context).pop(false),
                              //   child: Text(i18n.cancel),
                              // ),
                            ],
                          );
                        },
                      );
                    },
                    // onDismissed: (direction) => {
                    //
                    //     },
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
                      onTap: () => {
                        Navigator.of(context).pushNamed(EditExpensive.routeName,
                            arguments: {"id": transactions[i].id})
                      },
                      child: Card(
                          elevation: 3,
                          child: ListTile(
                            leading: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.calendar_today,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  size: 42.0,
                                ),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          Helper.formatDay(
                                              transactions[i].date),
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ]),
                              ],
                            ),
                            subtitle: Text(transactions[i].description!),
                            title: Text(Helper.formatCurrency(
                                metadata.currency, transactions[i].volume)),
                            trailing: Text(
                                Helper.formatDateTime(transactions[i].date)),
                            // isThreeLine: true,
                          )),
                    )),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
