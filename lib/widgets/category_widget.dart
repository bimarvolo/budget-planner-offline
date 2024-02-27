import 'package:flutter/material.dart';

class CateWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  const CateWidget(this.title, this.subTitle);

  @override
  Widget build(BuildContext context) {
    return Container(
        // width: 120,
        height: 65,
        child: Card(
          elevation: 3,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        // color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.7),
                        fontWeight: FontWeight.bold)),
                Text(
                  subTitle,
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ));
  }
}
