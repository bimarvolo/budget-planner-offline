import 'package:flutter/material.dart';
import 'package:money_budget_frontend/providers/budget.dart';
import 'package:money_budget_frontend/providers/budgets.dart';
import 'package:money_budget_frontend/providers/metadata.dart';
import 'package:provider/provider.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:money_budget_frontend/helpers/helper.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/categories.dart';
import '../providers/category.dart';

class AddCategory extends StatefulWidget {
  static const routeName = '/category-add';

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final _form = GlobalKey<FormState>();
  var _newCategory = Category(
    id: null,
    budgetId: null,
    type: '',
    description: '',
    volume: 0.0,
    totalSpent: 0.0,
  );

  Budget _budget;

  CategoryType _categoryType = CategoryType.expensive;

  Icon _icon;
  IconData _iconData;

  _pickIcon() async {
    IconData icon = await FlutterIconPicker.showIconPicker(context);

    _iconData = icon;
    _icon = Icon(icon);
    setState(() {});
  }

  void _saveForm(BuildContext ctx) async {
    var isValidated = _form.currentState.validate();
    if (!isValidated) return;

    _form.currentState.save();
    _newCategory = Category(
        id: null,
        budgetId: _budget.id,
        description: _newCategory.description,
        type: _categoryType == CategoryType.expensive ? 'expensive' : 'income',
        volume: _newCategory.volume,
        totalSpent: 0.0,
        iconData: _iconData == null ? Icons.category : _iconData);

    try {
      await Provider.of<Categories>(ctx, listen: false)
          .addCategory(_newCategory);

      final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context).msgCreateCategorySuccess));
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
      Navigator.of(ctx).pop();
    } catch (error) {
      Helper.showPopup(
          ctx, error, AppLocalizations.of(context).msgCreateCategoryFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    var metaData = Provider.of<Metadata>(context, listen: false);
    var budget = Provider.of<Budgets>(context, listen: false)
        .findById(metaData.currentBudget);
    setState(() {
      _budget = budget;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).addCategory),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
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
              Text(
                  '${AppLocalizations.of(context).forBudget} ${_budget.titleDisplay}'),
              SizedBox(
                height: 10,
              ),
              Text(AppLocalizations.of(context).categoryType),
              Row(
                children: [
                  Flexible(
                    child: RadioListTile<CategoryType>(
                      title: Text(AppLocalizations.of(context).expensive),
                      value: CategoryType.expensive,
                      groupValue: _categoryType,
                      onChanged: (CategoryType value) {
                        setState(() {
                          _categoryType = value;
                        });
                      },
                    ),
                  ),
                  Flexible(
                    child: RadioListTile<CategoryType>(
                      title: Text(AppLocalizations.of(context).income),
                      value: CategoryType.income,
                      groupValue: _categoryType,
                      onChanged: (CategoryType value) {
                        setState(() {
                          _categoryType = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).description),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty)
                    return AppLocalizations.of(context)
                        .pleaseProvideDescription;
                  return null;
                },
                onSaved: (value) {
                  _newCategory = Category(
                    type: _newCategory.type,
                    description: value,
                    volume: _newCategory.volume,
                    totalSpent: 0.0,
                    id: null,
                    budgetId: null,
                  );
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: _categoryType == CategoryType.expensive
                        ? AppLocalizations.of(context).budgetedAmount
                        : AppLocalizations.of(context).incomeGoal),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value.isEmpty)
                    return AppLocalizations.of(context).pleaseProvideAVolume;

                  if (double.tryParse(value) == null)
                    return AppLocalizations.of(context)
                        .pleaseProvideAValidNumber;

                  if (double.parse(value) <= 0)
                    return AppLocalizations.of(context)
                        .pleaseEnterNumberGreaterThanZero;

                  return null;
                },
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _newCategory = Category(
                      type: _newCategory.type,
                      volume: double.parse(value),
                      totalSpent: 0.0,
                      description: _newCategory.description,
                      id: null,
                      budgetId: null);
                },
              ),
              SizedBox(
                height: 10,
              ),
              Row(children: <Widget>[
                TextButton(
                  onPressed: _pickIcon,
                  child: Text('Pick an icon'),
                ),
                SizedBox(height: 10),
                AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: _icon != null ? _icon : Container())
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
