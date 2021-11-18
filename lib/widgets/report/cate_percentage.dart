import 'package:flutter/material.dart';

class CatePercentage {
  final String transName;
  final int percent;
  final int index;
  Color color;

  CatePercentage(
      {@required this.transName, @required this.percent, @required this.index, this.color});

  @override
  String toString() {
    return '$transName: $percent%';
  }

}
