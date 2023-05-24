import 'package:flutter/material.dart';

class CatePercentage {
  final String transName;
  final int percent;
  late int index;
  late Color color;

  CatePercentage(
      {required this.transName, required this.percent, required this.index});

  @override
  String toString() {
    return '$transName: $percent%';
  }
}
