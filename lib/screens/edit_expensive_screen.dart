import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';

import '../screens/add_category_screen.dart';
import '../providers/transaction.dart';
import '../providers/transactions.dart';
import '../providers/categories.dart';
import '../providers/category.dart';

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
      id: null, categoryId: null, description: '', volume: 0.0, date: null);

  Category _categorySelected;
  DateTime _selectedDate = DateTime.now();

  void _onNewCategoryTouch(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(AddCategory.routeName);
  }

  void _saveForm(BuildContext ctx, String oldCateId, String newCateId, Transaction oldTrans) async {

    var isValidated = _form.currentState.validate();
    if(!isValidated) return;

    _form.currentState.save();
    _newExpensive = Transaction(
        id: oldTrans.id,
        categoryId: _categorySelected.id,
        description: _newExpensive.description,
        volume: _newExpensive.volume,
        date: _selectedDate);

    try {
      await Provider.of<Transactions>(ctx, listen: false)
          .updateTransaction(_newExpensive);

      if(oldCateId != newCateId) {
        Provider.of<Categories>(ctx, listen: false)
            .increaseTotalSpent(oldCateId, (-1 * oldTrans.volume));
        Provider.of<Categories>(ctx, listen: false)
            .increaseTotalSpent(newCateId, _newExpensive.volume);

        Provider.of<Transactions>(ctx, listen: false).localDeleteTransaction(_newExpensive.id);

      } else {
        Provider.of<Categories>(ctx, listen: false)
            .increaseTotalSpent(_categorySelected.id, _newExpensive.volume - oldTrans.volume);
      }

      final snackBar =
          SnackBar(content: Text('Expensive has been updated!'));
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
            FlatButton(
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

    Transaction trans =
    Provider.of<Transactions>(context, listen: false).findById(widget.expensiveId);

    if(_categorySelected == null) {
      _categorySelected =
          categories.firstWhere((cate) => cate.id == trans.categoryId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expensive'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            color: Theme.of(context).accentColor,
            iconSize: 40,
            onPressed: () => _saveForm(context, trans.categoryId, _categorySelected.id, trans),
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
                        color: Theme.of(context).accentColor,
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
                          child: Text(
                              '${new ReCase(value.description).pascalCase}'),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Theme.of(context).accentColor,),
                      iconSize: 30,
                      onPressed: () => _onNewCategoryTouch(context),
                    ),
                  )
                ],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                textInputAction: TextInputAction.next,
                initialValue: trans.description,
                validator: (value) {
                  if (value.isEmpty) return 'please provide description!';
                  return null;
                },
                onSaved: (value) {
                  _newExpensive = Transaction(
                    description: value,
                    volume: _newExpensive.volume,
                    id: trans.id,
                    date: trans.date,
                    categoryId: _categorySelected.id,
                  );
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Amount'),
                textInputAction: TextInputAction.done,
                initialValue: trans.volume.toString(),
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
                    id: trans.id,
                    date: trans.date,
                    categoryId: _categorySelected.id
                  );
                },
              ),
              SizedBox(height: 20,),
              Text('Transaction date: '),
              Container(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: OutlineButton(
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
                      child: OutlineButton(
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
