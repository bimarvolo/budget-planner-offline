import '../providers/category.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../helpers/helper.dart';
import '../providers/categories.dart';
import '../widgets/pie_chart.dart';
import '../widgets/report/budget_percent_done_chart.dart';
import '../widgets/report/cate_percentage.dart';

class Report extends StatefulWidget {
  static const routeName = '/report';

  @override
  _ReportState createState() => _ReportState();
}

List<Category> _tempCates = [
  new Category(
      id: '1',
      description: 'temp',
      type: 'expensive',
      volume: 4,
      totalSpent: 2,
      iconData: null),
  new Category(
      id: '2',
      description: 'temp2',
      type: 'expensive',
      volume: 4,
      totalSpent: 2,
      iconData: null),
  new Category(
      id: '3',
      description: 'temp3',
      type: 'expensive',
      volume: 5,
      totalSpent: 3,
      iconData: null),
  new Category(
      id: '4',
      description: 'temp4',
      type: 'expensive',
      volume: 5,
      totalSpent: 3,
      iconData: null),
  new Category(
      id: '5',
      description: 'temp5',
      type: 'expensive',
      volume: 10,
      totalSpent: 3,
      iconData: null),
];

class _ReportState extends State<Report> {
  @override
  Widget build(BuildContext context) {
    var accentColor = Theme.of(context).accentColor;
    final List<Color> pieColors = [
      accentColor.withOpacity(.8),
      accentColor.withOpacity(.4),
      accentColor.withOpacity(.6),
      accentColor.withOpacity(.2),
    ];

    var expensiveCates =
        Provider.of<Categories>(context, listen: true).expensiveCategories;

    Color getColorFromIndex(int index) {
      if (Provider.of<Categories>(context, listen: false)
              .expensiveCategories
              .length ==
          0) return Colors.grey;

      return pieColors[(index % pieColors.length)];
    }

    if (expensiveCates.length == 0) {
      expensiveCates = _tempCates;
    }

    final budgeted = expensiveCates.fold<double>(0, (i, el) {
      return i + el.volume;
    });

    var expenditure = expensiveCates.fold<double>(0, (i, el) {
      return i + el.totalSpent;
    });

    if (expenditure == 0.0) expenditure = -1;

    List<CatePercentage> barData1 = expensiveCates
        .map((e) => new CatePercentage(
            index: -1,
            transName: e.description,
            percent: e.totalSpent < e.volume
                ? (e.totalSpent / e.volume * 100).round()
                : 100))
        .toList();
    List<CatePercentage> barData2 = expensiveCates
        .map((e) => new CatePercentage(
            index: -1,
            transName: e.description,
            percent: e.totalSpent < e.volume
                ? ((1 - e.totalSpent / e.volume) * 100).round()
                : 0))
        .toList();

    final List fixedList =
        Iterable<int>.generate(expensiveCates.length).toList();

    List<CatePercentage> pieData1 = fixedList
        .map((idx) => new CatePercentage(
            transName: expensiveCates[idx].description,
            index: idx,
            percent:
                (expensiveCates[idx].totalSpent * 100 / expenditure).round()))
        .toList();

    List<CatePercentage> pieData2 = fixedList
        .map((idx) => new CatePercentage(
            transName: expensiveCates[idx].description,
            index: idx,
            percent: (expensiveCates[idx].volume * 100 / budgeted).round()))
        .toList();

    List<charts.Series<CatePercentage, String>> barChartData = [
      new charts.Series<CatePercentage, String>(
        id: 'Already spend',
        colorFn: (_, __) => Helper.getChartColor(getColorFromIndex(0)),
        domainFn: (CatePercentage percent, _) => percent.transName,
        measureFn: (CatePercentage percent, _) => percent.percent,
        data: barData1,
      ),
      new charts.Series<CatePercentage, String>(
        id: 'Total spend',
        colorFn: (_, __) => Helper.getChartColor(Colors.grey),
        domainFn: (CatePercentage percent, _) => percent.transName,
        measureFn: (CatePercentage percent, _) => percent.percent,
        data: barData2,
      ),
    ];

    List<charts.Series<CatePercentage, num>> pieChartData = [
      new charts.Series<CatePercentage, num>(
        id: 'Sales',
        domainFn: (CatePercentage cate, _) => cate.index,
        measureFn: (CatePercentage cate, _) => cate.percent,
        colorFn: (CatePercentage cate, __) =>
            Helper.getChartColor(getColorFromIndex(cate.index)),
        data: pieData1,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (CatePercentage cate, _) => cate.percent != 0
            ? '${cate.transName} (${cate.percent}%)'
            : '${AppLocalizations.of(context)!.other} (0%)',
      )
    ];

    List<charts.Series<CatePercentage, num>> pieChartData2 = [
      new charts.Series<CatePercentage, num>(
        id: 'Sales2',
        domainFn: (CatePercentage cate, _) => cate.index,
        measureFn: (CatePercentage cate, _) => cate.percent,
        colorFn: (CatePercentage cate, __) =>
            Helper.getChartColor(getColorFromIndex(cate.index)),
        data: pieData2,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (CatePercentage cate, _) =>
            cate.percent != 0 ? '${cate.transName} (${cate.percent}%)' : '123',
      )
    ];

    return SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.progressByCategory,
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              Container(
                width: double.infinity,
                height: 200,
                child: StackedHorizontalBarChart(barChartData, animate: true),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                AppLocalizations.of(context)!.budgetedByCategory,
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              Container(
                  width: double.infinity,
                  height: 160,
                  // child: DonutPieChart.withSampleData()),
                  child: PieOutsideLabelChart(pieChartData2,
                      Helper.getChartColor(getColorFromIndex(0)))),
              SizedBox(
                height: 20,
              ),
              if (expenditure != -1)
                Text(
                  AppLocalizations.of(context)!.expenditureByCategory,
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              if (expenditure != -1)
                Container(
                    width: double.infinity,
                    height: 160,
                    child: PieOutsideLabelChart(pieChartData,
                        Helper.getChartColor(getColorFromIndex(0)))),
            ],
          )),
    );
  }
}
