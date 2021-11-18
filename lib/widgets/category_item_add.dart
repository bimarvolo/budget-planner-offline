import 'package:flutter/material.dart';

import '../providers/category.dart';

class CategoryItemAdd extends StatelessWidget {
  CategoryItemAdd();

  @override
  Widget build(BuildContext context) {
    return Card(
      // elevation: 3,
      margin: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.category, color: Colors.grey,),
            Container(
              alignment: Alignment.center,
              child: Text('Add New Category', style: TextStyle(color: Colors.grey),),
            ),
            // SizedBox(
            //   height: 25,
            // ),
          ],
        ),
      ),
    );
  }
}
