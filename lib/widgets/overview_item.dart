import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

import '../providers/categories.dart';
import '../providers/category.dart';

class OverviewItem extends StatefulWidget {
  OverviewItem();

  @override
  _OverviewItemState createState() => _OverviewItemState();
}

class _OverviewItemState extends State<OverviewItem> {
  int touchedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final categories =
        Provider.of<Categories>(context, listen: true).expensiveCategories;

    return AspectRatio(
      aspectRatio: 1.2,
      child: Card(
        // color: Colors.white,
        elevation: 6,
        child: AspectRatio(
          aspectRatio: 1,
          child: PieChart(
            PieChartData(
                // pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                //   setState(() {
                //     final desiredTouch = pieTouchResponse.touchInput is! PointerExitEvent &&
                //         pieTouchResponse.touchInput is! PointerUpEvent;
                //     if (desiredTouch && pieTouchResponse.touchedSection != null) {
                //       touchedIndex = pieTouchResponse.touchedSection.touchedSectionIndex;
                //     } else {
                //       touchedIndex = -1;
                //     }
                //   });
                // }),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                sections: showingSections(categories)),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(List<Category> categories) {
    const colors = [
      Color(0xff0293ee),
      Color(0xfff8b250),
      Color(0xff845bef),
      Color(0xff13d38e),
      Color(0xff845bef)
    ];
    return List.generate(categories.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 15.0 : 13.0;
      final radius = isTouched ? 105.0 : 100.0;
      final widgetSize = isTouched ? 45.0 : 40.0;

      Category cate = categories[i];

      return PieChartSectionData(
        color: colors[i],
        value: cate.totalSpent,
        title: '${cate.totalSpent} \$',
        radius: radius,
        titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff)),
        badgeWidget: _Badge(
          cate.description,
          size: widgetSize,
          borderColor: colors[i],
          key: Key(cate.id),
        ),
        badgePositionPercentageOffset: 1.2,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  final String title;
  final double size;
  final Color borderColor;

  const _Badge(
    this.title, {
    required Key key,
    required this.size,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size * 3,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Text(title),
      ),
    );
  }
}
