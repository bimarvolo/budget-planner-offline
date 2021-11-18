import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../helpers/helper.dart';
import '../providers/metadata.dart';
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

  Future<void> _onTransDelete(ctx, transId, volume) async {
    bool isDeleted = false;
    try {
      isDeleted = await Provider.of<Transactions>(context, listen: false)
          .deleteTransaction(transId);
      if(isDeleted) {
        final snackBar =
        SnackBar(content: Text(AppLocalizations.of(context).msgDeleteExpenseSuccess));
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
        Provider.of<Categories>(ctx, listen: false)
            .decreaseTotalSpent(widget.categoryId, volume);
        Navigator.of(context).pop(true);
      } else {
        final snackBar =
        SnackBar(content: Text(AppLocalizations.of(context).msgDeleteExpenseFailed));
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
        Navigator.of(context).pop(false);
      }
    } catch (error) {
      Navigator.of(ctx).pop(false);
      Helper.showPopup(ctx, error, AppLocalizations.of(context).msgDeleteExpenseFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    Category category;
    List<Category> categories =
        Provider.of<Categories>(context, listen: true).expensiveCategories;
    if (categories.length != 0) {
      if (widget.categoryId != null) {
        category =
            categories.firstWhere((cate) => cate.id == widget.categoryId);
      } else {
      }
    }

    List<Transaction> transactions = Provider.of<Transactions>(context).items;

    return Scaffold(
      appBar: AppBar(
        title: Text('${category.description}'),
        actions: [
          IconButton(
            icon: Icon(Icons.add,
              color: Theme.of(context).accentColor,
            ),
            // iconSize: 40,
            onPressed: () => {
              Navigator.of(context)
                  .pushNamed(AddExpensive.routeName, arguments: {
                'id': widget.categoryId,
              }),
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Text(
                        AppLocalizations.of(context).youSpent,
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        // '${category.totalSpent}',
                        '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, category.totalSpent)}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ]),
                    Row(children: [
                      Text(
                        '${AppLocalizations.of(context).budget} :',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, category.volume)}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ]),
                  ],
                ),

                SizedBox(
                  height: 5,
                ),
                SpendBar(
                    category.volume, category.totalSpent / category.volume),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  height: 800,
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
                                    title: Text(AppLocalizations.of(context).confirm),
                                    content: Text(AppLocalizations.of(context).areYouSureYouWishToDeleteThisItem),
                                    actions: <Widget>[
                                      FlatButton(
                                          onPressed: () => {
                                            _onTransDelete(context, transactions[i].id, transactions[i].volume)
                                            },
                                          child: Text(AppLocalizations.of(context).delete),
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
                            // onDismissed: (direction) => {
                            //
                            //     },
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
                              onTap: () => {
                                Navigator.of(context).pushNamed(
                                    EditExpensive.routeName,
                                    arguments: {"id": transactions[i].id})
                              },
                              child: Card(
                                elevation: 3,
                                child: ListTile(
                                  // leading: FlutterLogo(size: 52.0),
                                  // leading:  Icon(Icons.calendar_today_sharp, size: 52,),
                                  leading: Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      Icon(
                                        Icons.calendar_today,
                                        color: Theme.of(context).accentColor,
                                        // color: Colors.blueGrey,
                                        size: 48.0,
                                      ),

                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [ Padding(
                                          padding: const EdgeInsets.only(top: 0),
                                          child: Text(
                                            Helper.formatDay(transactions[i].date),
                                            style: TextStyle(fontSize: 15,
                                                // color: Colors.blueGrey,
                                                color: Theme.of(context).accentColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                          // Text(
                                          //   Helper.formatMonth(transactions[i].date),
                                          //   style: TextStyle(fontSize: 9,color: Colors.blueGrey, fontWeight: FontWeight.bold),
                                          // ),
                                        ]
                                      ),
                                    ],
                                  ),
                                  subtitle : Text(transactions[i].description),
                                  title: Text(Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, transactions[i].volume)),
                                  trailing: Text(Helper.formatDateTime(transactions[i].date)),
                                  // isThreeLine: true,
                                )
                              ),
                            )),
                      ),
                ),
              ]),
        ),
      ),
    );
  }
}
