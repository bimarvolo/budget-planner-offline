import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'add_budget_screen.dart';

class ExpenseEmpty extends StatefulWidget {
  @override
  _ExpenseState createState() => _ExpenseState();
}

class _ExpenseState extends State<ExpenseEmpty> {
  @override
  Widget build(BuildContext context) {
    var i18n = AppLocalizations.of(context)!;

    return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 20),
                child: Column(children: [
                  Text(
                    i18n.youDoNotHaveBudgets,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    child: Text(i18n.createFirstBudget),
                    onPressed: () =>
                        {Navigator.of(context).pushNamed(AddBudget.routeName)},
                  )
                ])),
          ]),
        ));
  }
}
