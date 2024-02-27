import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_budget_frontend_offile/hive/metadata_storage.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';

import '../providers/budget.dart';
import '../providers/metadata.dart';
import '../screens/add_category_screen.dart';
import '../providers/transaction.dart';
import '../providers/transactions.dart';
import '../providers/categories.dart';
import '../providers/category.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditExpensive extends StatefulWidget {
  static const routeName = '/expensive-edit';

  final String expensiveId;
  EditExpensive(this.expensiveId);

  @override
  _EditExpensiveState createState() => _EditExpensiveState();
}

class _EditExpensiveState extends State<EditExpensive> {
  final _form = GlobalKey<FormState>();
  var _newExpensive = Transaction(
      id: '',
      description: '',
      volume: 0.0,
      categoryId: '',
      date: DateTime(2023));

  Category? _categorySelected;
  DateTime _selectedDate = DateTime.now();

  void _onNewCategoryTouch(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(AddCategory.routeName);
  }

  void _saveForm(BuildContext ctx, String oldCateId, String newCateId,
      Transaction oldTrans, int currentBudget) async {
    var isValidated = _form.currentState!.validate();
    if (!isValidated) return;

    bool isCategoryChange = oldCateId != newCateId && newCateId != "";

    _form.currentState!.save();
    _newExpensive = Transaction(
        id: oldTrans.id,
        categoryId: isCategoryChange ? newCateId : oldTrans.categoryId,
        description: _newExpensive.description,
        volume: _newExpensive.volume,
        date: _selectedDate);

    try {
      await Provider.of<Transactions>(ctx, listen: false)
          .updateTransaction(_newExpensive);

      Box budgetsBox = Hive.box<Budget>('budgets');
      Budget updateBudget = budgetsBox.values.elementAt(currentBudget);
      if (isCategoryChange) {
        updateBudget.categories = updateBudget.categories.map((cate) {
          if (cate.id == newCateId) {
            cate.totalSpent += _newExpensive.volume;
          } else if (cate.id == oldCateId) {
            cate.totalSpent -= oldTrans.volume;
          }
          return cate;
        }).toList();
      } else {
        updateBudget.categories = updateBudget.categories.map((cate) {
          if (cate.id == oldCateId) {
            cate.totalSpent += _newExpensive.volume - oldTrans.volume;
          }
          return cate;
        }).toList();
      }

      budgetsBox.put(updateBudget.id, updateBudget);
      Provider.of<Categories>(context, listen: false).notifyDataChange();

      if (isCategoryChange) {
        Provider.of<Transactions>(context, listen: false)
            .localDeleteTransaction(_newExpensive.id);
      }

      final snackBar = SnackBar(
          content: Text('Expensive has been updated!'),
          duration: Duration(seconds: 1));
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
      Navigator.of(ctx).pop();
    } catch (error) {
      print(error);
      await showDialog(
        context: ctx,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
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

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
  }

  void _presentTimePicker() {
    showTimePicker(
            context: context,
            initialTime: TimeOfDay(
                hour: _selectedDate.hour, minute: _selectedDate.minute))
        .then((pickedTime) {
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

    Transaction trans = Provider.of<Transactions>(context, listen: false)
        .findById(widget.expensiveId);
    // TODO

    if (_categorySelected == null) {
      _categorySelected =
          categories.firstWhere((cate) => cate.id == trans.categoryId);
    }

    _selectedDate = trans.date;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expensive'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            color: Theme.of(context).colorScheme.secondary,
            iconSize: 40,
            onPressed: () => null,
          ),
        ],
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
//                    style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        // color: Colors.deepPurpleAccent,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onChanged: (Category? newValue) {
                        setState(() {
                          _categorySelected = newValue;
                          _newExpensive = Transaction(
                              volume: _newExpensive.volume,
                              categoryId: _categorySelected!.id,
                              description: _newExpensive.description,
                              id: trans.id,
                              date: trans.date);
                        });
                      },
                      items: categories
                          .map<DropdownMenuItem<Category>>((Category value) {
                        return DropdownMenuItem<Category>(
                          value: value,
                          child: Text(
                              '${new ReCase(value.description).pascalCase}'),
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
                cursorColor: Theme.of(context).colorScheme.secondary,
                decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    prefix: Text(metadata!.currency,
                        style: TextStyle(fontSize: 18))),
                textInputAction: TextInputAction.done,
                initialValue: trans.volume.toString(),
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
                      categoryId: _categorySelected!.id,
                      description: _newExpensive.description,
                      id: trans.id,
                      date: trans.date);
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
                initialValue: trans.description,
                onSaved: (value) {
                  _newExpensive = Transaction(
                    description: value,
                    categoryId: _categorySelected!.id,
                    volume: _newExpensive.volume,
                    id: trans.id,
                    date: trans.date,
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),
              Text('Transaction date: '),
              Container(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        child: Text(
                          _selectedDate == null
                              ? 'No Date Chosen!'
                              : '${DateFormat.yMd().format(_selectedDate)}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
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
                              color: Theme.of(context).colorScheme.secondary),
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
                    onPressed: () => _saveForm(
                        context,
                        trans.categoryId!,
                        _newExpensive.categoryId!,
                        trans,
                        metadata.currentBudget),
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
