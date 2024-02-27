import 'package:flutter/material.dart';

class DotWidget extends StatelessWidget {
  const DotWidget({
    required Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: Theme.of(context).colorScheme.secondary),
      height: 10,
      width: 10,
    );
  }
}