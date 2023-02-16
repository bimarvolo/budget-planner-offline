import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Helper {
  static String formatCurrency(currency, value) {
    return NumberFormat.currency(name: currency).format(value);
  }

  static void showMessage(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        // backgroundColor: Colors.red,
        // textColor: Colors.white,
        fontSize: 16.0);
  }

  static String formatDateTime(value) {
    return '${formatDate(value)} ${formatTime(value)}';
  }

  static String formatDate(value) {
    return '${DateFormat.yMMMd().format(value)}';
  }

  static String formatShortDate(value) {
    return '${DateFormat.MMMd().format(value)}';
  }

  static String formatMonth(value) {
    return '${DateFormat.MMM().format(value)}';
  }

  static String formatDay(value) {
    return '${DateFormat.d().format(value)}';
  }

  static String formatTime(value) {
    return '${DateFormat.Hm().format(value)}';
  }

  static charts.Color getChartColor(Color color) {
    return charts.Color(
        r: color.red, g: color.green, b: color.blue, a: color.alpha);
  }

  static Future<void> showPopup(context, error, defaultMessage) async {
    print(error);
    String message = defaultMessage;
    try {
      if (error?.osError?.errorCode == 7) {
        message = AppLocalizations.of(context).youAreOffline;
      }
    } catch (e) {}

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).anErrorOccurred),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }
}
