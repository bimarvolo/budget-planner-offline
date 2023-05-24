import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../helpers/helper.dart';
import '../providers/metadata.dart';

class SpendBar extends StatelessWidget {
  final double totalAmount;
  final double spendingPctOfTotal;

  SpendBar(this.totalAmount, this.spendingPctOfTotal);

  @override
  Widget build(BuildContext context) {
    // List<Color> colors = [Theme.of(context).backgroundColor, Colors.amber.shade200, Theme.of(context).accentColor];
    List<Color> colors = [
      Colors.amber.shade100,
      Colors.amber.shade400,
      Colors.amber.shade800
    ];
    // List<Color> colors = [Colors.deepOrangeAccent[20], Colors.deepOrangeAccent[50], Colors.deepOrangeAccent[80] ];
    // List<Color> colors = [Theme.of(context).backgroundColor, Colors.amber, Theme.of(context).accentColor ];
    var remaining = (1 - spendingPctOfTotal) * totalAmount;

    return LayoutBuilder(builder: (ctx, constraint) {
      return Row(
        children: [
          Container(
            height: 17,
            width: constraint.maxWidth,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    // color: Color.fromRGBO(220, 220, 220, 1),
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                AnimatedContainer(
                  width: constraint.maxWidth * spendingPctOfTotal,
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeIn,
                  decoration: BoxDecoration(
                      color: spendingPctOfTotal > 1
                          ? colors[2]
                          : spendingPctOfTotal <= 0.8
                              ? colors[0]
                              : colors[1],
                      borderRadius: BorderRadius.circular(10)),
                ),
                Center(
                  child: Text(
                    remaining >= 0
                        ? '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, remaining)} ${AppLocalizations.of(context)!.remaining}'
                        : '${Helper.formatCurrency(Provider.of<Metadata>(context, listen: false).currency, remaining * -1)} ${AppLocalizations.of(context)!.overSpent}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
//          SizedBox(
//            height: constraint.maxHeight * 0.05,
//          ),

//          Container(
//              height: constraint.maxHeight * 0.15,
//              child: FittedBox(child: Text(label)))
        ],
      );
    });
  }
}
