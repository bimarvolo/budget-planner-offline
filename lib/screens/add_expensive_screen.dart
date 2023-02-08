import 'package:flutter/material.dart';
import 'package:money_budget_frontend/helpers/helper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../screens/add_category_screen.dart';
import '../providers/transaction.dart';
import '../providers/transactions.dart';
import '../providers/categories.dart';
import '../providers/category.dart';

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
      id: null, categoryId: null, description: '', volume: 0.0, date: null);

  Category _categorySelected;
  DateTime _selectedDate = DateTime.now();

  void _onNewCategoryTouch(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(AddCategory.routeName);
  }

  void _saveForm(BuildContext ctx) async {
    var isValidated = _form.currentState.validate();
    if (!isValidated) return;

    _form.currentState.save();
    _newExpensive = Transaction(
        id: null,
        categoryId: _categorySelected.id,
        description: _newExpensive.description,
        volume: _newExpensive.volume,
        date: _selectedDate);

    try {
      await Provider.of<Transactions>(ctx, listen: false)
          .addTransaction(_newExpensive);

      Provider.of<Categories>(ctx, listen: false)
          .increaseTotalSpent(_categorySelected.id, _newExpensive.volume);

      final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context).msgCreateExpenseSuccess));

      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
      Navigator.of(ctx).pop();
    } catch (error) {
      Helper.showPopup(
          ctx, error, AppLocalizations.of(context).msgCreateExpenseFailed);
    }
  }

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
    List<Category> categories =
        Provider.of<Categories>(context, listen: false).expensiveCategories;
    if (categories.length != 0) {
      if (widget.categoryId != null) {
        _categorySelected =
            categories.firstWhere((cate) => cate.id == widget.categoryId);
      } else {
        if (_categorySelected == null) _categorySelected = categories[0];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expensive'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: Theme.of(context).accentColor,
            ),
            iconSize: 40,
            onPressed: () => _saveForm(context),
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
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (Category newValue) {
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
                        color: Theme.of(context).accentColor,
                      ),
                      iconSize: 30,
                      onPressed: () => _onNewCategoryTouch(context),
                    ),
                  )
                ],
              ),
              TextFormField(
                autofocus: widget.categoryId != null,
                decoration: InputDecoration(labelText: 'Amount'),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value.isEmpty) return 'please provide a amount!';

                  if (double.tryParse(value) == null)
                    return 'please enter a valid number!';

                  if (double.parse(value) <= 0)
                    return 'please enter a number greater than zero!';

                  return null;
                },
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _newExpensive = Transaction(
                    volume: double.parse(value),
                    description: _newExpensive.description,
                    id: null,
                    date: null,
                    categoryId:
                        _categorySelected != null ? _categorySelected.id : null,
                  );
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _newExpensive = Transaction(
                    description: value,
                    volume: _newExpensive.volume,
                    id: null,
                    date: null,
                    categoryId:
                        _categorySelected != null ? _categorySelected.id : null,
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
//                      textColor: Theme.of(context).primaryColor,
                        child: Text(
                          _selectedDate == null
                              ? 'No Date Chosen!'
                              : '${DateFormat.yMd().format(_selectedDate)}',
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _presentTimePicker,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
