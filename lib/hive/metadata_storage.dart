// Import necessary packages
import 'package:hive/hive.dart';

import '../providers/budget.dart';
import '../providers/user_metadata.dart';

// Define a class for storing and retrieving user metadata
class MetadataStorage {
  // Hive box name for user metadata
  static const String _boxName = 'metadata';

  // Store user metadata in Hive box
  static void initMetadata() {
    var box = Hive.box(_boxName);
    var metadata = UserMetadata()
      ..lang
      ..currentBudget
      ..currency
      ..theme;

    box.put('metadata', metadata);
  }

  static void storeCurrentBudget(int currentBudget) {
    var box = Hive.box(_boxName);
    var metadata = getMetadata();

    if (metadata == null) {
      initMetadata();
      metadata = getMetadata();
    }

    metadata!.currentBudget = currentBudget;
    box.put('metadata', metadata);
  }

  static void storeTheme(String themeName) {
    var box = Hive.box(_boxName);
    var metadata = getMetadata();

    if (metadata == null) {
      initMetadata();
      metadata = getMetadata();
    }

    metadata!.theme = themeName;
    box.put('metadata', metadata);
  }

  static void storeLang(String lang) {
    var box = Hive.box(_boxName);
    var metadata = getMetadata();
    if (metadata == null) {
      initMetadata();
      metadata = getMetadata();
    }

    metadata!.lang = lang;
    box.put('metadata', metadata);
  }

  static void storeCurrency(String cu) {
    var box = Hive.box(_boxName);
    var metadata = getMetadata();

    if (metadata == null) {
      initMetadata();
      metadata = getMetadata();
    }

    metadata!.currency = cu;
    box.put('metadata', metadata);
  }

  // Retrieve user metadata from Hive box
  static UserMetadata? getMetadata() {
    var box = Hive.box(_boxName);
    var metadata = box.get('metadata') as UserMetadata?;

    return metadata;
  }

  static Budget? GetCurrentBudget() {
    Box budgetsBox = Hive.box<Budget>('budgets');
    var metadata = getMetadata();
    if (metadata != null && metadata.currentBudget != -1) {
      var budget = budgetsBox.getAt(metadata.currentBudget);
      return budget!;
    }
    return null;
  }
}
