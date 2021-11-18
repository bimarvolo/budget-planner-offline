import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../../helpers/helper.dart';

class StackedHorizontalBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final num fontSize = 11;

  StackedHorizontalBarChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    // For horizontal bar charts, set the [vertical] flag to false.
    return new charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.stacked,
      domainAxis: new charts.OrdinalAxisSpec(
          renderSpec: new charts.SmallTickRendererSpec(

              // Tick and Label styling here.
              labelStyle: new charts.TextStyleSpec(
                  fontSize: fontSize, // size in Pts.
                  color: Helper.getChartColor(Colors.grey)
              ),
              // Change the line colors to match text color.
              lineStyle: new charts.LineStyleSpec(
                  color: Helper.getChartColor(Colors.grey)
              ))),
      /// Assign a custom style for the measure axis.
      primaryMeasureAxis: new charts.NumericAxisSpec(
          renderSpec: new charts.GridlineRendererSpec(

            // Tick and Label styling here.
              labelStyle: new charts.TextStyleSpec(
                  fontSize: fontSize, // size in Pts.
                  color: Helper.getChartColor(Colors.grey)),

              // Change the line colors to match text color.
              lineStyle: new charts.LineStyleSpec(
                  color: Helper.getChartColor(Colors.grey)))),
      vertical: false,
    );
  }
}