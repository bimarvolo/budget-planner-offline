import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../hive/metadata_storage.dart';
import '../helpers/helper.dart';
import '../providers/budget.dart';
import '../screens/add_category_screen.dart';
import '../providers/transaction.dart';
import '../providers/transactions.dart';
import '../providers/categories.dart';
import '../providers/category.dart';

/// Represents a screen for adding an expense.
/// This screen is used to input and save information about a new expense.
/// It is a stateful widget, allowing for dynamic updates based on user input.
class AddExpensive extends StatefulWidget {
  static const routeName = '/expensive-add';

  final String categoryId;
  AddExpensive(this.categoryId);

  @override
  _AddExpensiveState createState() => _AddExpensiveState();
}

class _AddExpensiveState extends State<AddExpensive> {
  final _form = GlobalKey<FormState>();
  var _newExpensive = Transaction(
      id: '',
      categoryId: "",
      description: '',
      volume: 0.0,
      date: DateTime(2023));

  Category? _categorySelected;
  DateTime _selectedDate = DateTime.now();

  void _onNewCategoryTouch(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(AddCategory.routeName);
  }

  /// Saves the form data and updates the budget.
  ///
  /// This method takes the [BuildContext] and [currentBudget] as parameters.
  /// It is an asynchronous method that saves the form data and updates the budget.
  ///
  /// Example usage:
  /// ```dart
  /// _saveForm(context, currentBudget);
  /// ```
  void _saveForm(BuildContext ctx, int currentBudget) async {
    var isValidated = _form.currentState!.validate();
    if (!isValidated) return;
    var uuid = Uuid();

    _form.currentState!.save();
    _newExpensive = Transaction(
        id: uuid.v4(),
        categoryId: _categorySelected!.id,
        description: _newExpensive.description,
        volume: _newExpensive.volume,
        date: _selectedDate);

    try {
      await Provider.of<Transactions>(ctx, listen: false)
          .addTransaction(_newExpensive);

      Box budgetsBox = Hive.box<Budget>('budgets');
      Budget updateBudget = budgetsBox.values.elementAt(currentBudget);
      updateBudget.categories = updateBudget.categories.map((cate) {
        if (cate.id == widget.categoryId) {
          cate.totalSpent += _newExpensive.volume;
        }
        return cate;
      }).toList();

      // Update DB
      budgetsBox.put(updateBudget.id, updateBudget);

      // Provider.of<Categories>(context, listen: false)
      //   .setItems(updateBudget.categories, notify: true);
      Provider.of<Categories>(context, listen: false).notifyDataChange();
      // show snackbar
      final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context)!.msgCreateExpenseSuccess),
        duration: Duration(seconds: 1));

      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
      Navigator.of(ctx).pop();
    } catch (error) {
      Helper.showPopup(
          ctx, error, AppLocalizations.of(context)!.msgCreateExpenseFailed);
    }
  }

  /// Presents a date picker to the user.
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2051),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = new DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, _selectedDate.hour, _selectedDate.minute);
      });
    });
    print('...');
  }

  /// Presents a time picker to the user.
  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        _selectedDate = new DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, pickedTime.hour, pickedTime.minute);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var metadata = MetadataStorage.getMetadata();
    List<Category> categories =
        Provider.of<Categories>(context, listen: false).expensiveCategories;
    if (categories.length != 0) {
      _categorySelected =
          categories.firstWhere((cate) => cate.id == widget.categoryId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expensive'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              Text('Pick a Category:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButton<Category>(
                      isExpanded: true,
                      value: _categorySelected,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      onChanged: (Category? newValue) {
                        setState(() {
                          _categorySelected = newValue;
                        });
                      },
                      items: categories
                          .map<DropdownMenuItem<Category>>((Category value) {
                        return DropdownMenuItem<Category>(
                          value: value,
                          child: Row(
                            children: [
                              Icon(value.iconData),
                              Text(' ${value.description}'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      iconSize: 30,
                      onPressed: () => _onNewCategoryTouch(context),
                    ),
                  )
                ],
              ),
              TextFormField(
                autofocus: widget.categoryId != null,
                cursorColor: Theme.of(context).colorScheme.secondary,
                decoration: InputDecoration(
                    labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                    labelText: 'Amount',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    prefix: Text(metadata!.currency,
                        style: TextStyle(fontSize: 18))),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value != null && value.isEmpty)
                    return 'please provide a amount!';

                  if (double.tryParse(value!) == null)
                    return 'please enter a valid number!';

                  if (double.parse(value) <= 0)
                    return 'please enter a number greater than zero!';

                  return null;
                },
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _newExpensive = Transaction(
                      volume: double.parse(value!),
                      description: _newExpensive.description,
                      id: '',
                      categoryId: _categorySelected!.id,
                      date: DateTime(2023));
                },
              ),
              TextFormField(
                cursorColor: Theme.of(context).colorScheme.secondary,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _newExpensive = Transaction(
                      description: value,
                      volume: _newExpensive.volume,
                      id: '',
                      categoryId: _categorySelected!.id,
                      date: DateTime(2023));
                },
              ),
              SizedBox(
                height: 20,
              ),
              Text('Transaction date: '),
              Container(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
//                      textColor: Theme.of(context).primaryColor,
                        child: Text(
                          _selectedDate == null
                              ? 'No Date Chosen!'
                              : '${DateFormat.yMd().format(_selectedDate)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        onPressed: _presentDatePicker,
                      ),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        child: Text(
                          _selectedDate == null
                              ? 'No Time Chosen!'
                              : '${DateFormat.Hm().format(_selectedDate)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        onPressed: _presentTimePicker,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  alignment: Alignment.topCenter,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            width: 1.3,
                            color: Theme.of(context).colorScheme.secondary),
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary),
                    onPressed: () => _saveForm(context, metadata.currentBudget),
                    icon: Icon(Icons.save, size: 24.0),
                    label: Text(AppLocalizations.of(context)!.save), // <-- Text
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
