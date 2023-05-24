import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/metadata.dart';
import '../providers/category.dart';
import '../providers/budget.dart';
import '../providers/budgets.dart';
import './overview_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum RangeSelection { THIS_MONTH, THIS_WEEK, THIS_DAY, NEXT_MONTH, NEXT_WEEK }

enum ExpensiveCategory {
  HOUSING,
  TRANSPORTATION,
  FOOD,
  UTILITIES,
  CLOTHING,
  MEDICAL_HEALTH_CARE,
  INSURANCE,
  EDUCATION,
  ENTERTAINMENT,
  CHILDCARE,
}

class AddBudget extends StatefulWidget {
  static const routeName = '/budget-add';

  @override
  _AddBudgetState createState() => _AddBudgetState();
}

class _AddBudgetState extends State<AddBudget> {
  final _form = GlobalKey<FormState>();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  RangeSelection _selection = RangeSelection.THIS_MONTH;
  List<Category> _cateExSelection = [];
  bool _activeExpensive = true;
  bool _activeIncome = true;

  final myController = TextEditingController();

  var _expensiveDefaults = [
    {
      'key': ExpensiveCategory.HOUSING,
      'name': 'Housing',
      'iconData': Icons.house,
      'checked': false
    },
    {
      'key': ExpensiveCategory.TRANSPORTATION,
      'name': 'Transportation',
      'iconData': Icons.electric_bike,
      'checked': false
    },
    {
      'key': ExpensiveCategory.FOOD,
      'name': 'Food',
      'iconData': Icons.ramen_dining,
      'checked': false
    },
    {
      'key': ExpensiveCategory.UTILITIES,
      'name': 'Utilities',
      'iconData': Icons.category,
      'checked': false
    },
    {
      'key': ExpensiveCategory.CLOTHING,
      'name': 'Clothing',
      'iconData': Icons.dry_cleaning,
      'checked': false
    },
    {
      'key': ExpensiveCategory.MEDICAL_HEALTH_CARE,
      'name': 'Medical/HealthCare',
      'iconData': Icons.medical_services,
      'checked': false
    },
    {
      'key': ExpensiveCategory.INSURANCE,
      'name': 'Insurance',
      'iconData': Icons.security,
      'checked': false
    },
    {
      'key': ExpensiveCategory.EDUCATION,
      'name': 'Education',
      'iconData': Icons.school,
      'checked': false
    },
    {
      'key': ExpensiveCategory.ENTERTAINMENT,
      'name': 'Entertainment',
      'iconData': Icons.sports_esports,
      'checked': false
    },
    {
      'key': ExpensiveCategory.CHILDCARE,
      'name': 'Childcare',
      'iconData': Icons.child_care,
      'checked': false
    },
  ];

  var _incomeDefaults = [
    {
      'key': 'SALARY',
      'name': 'Salary',
      'iconData': Icons.attach_money,
      'checked': false
    },
    {
      'key': 'OTHERS',
      'name': 'Other income',
      'iconData': Icons.request_quote,
      'checked': false
    },
  ];

  var _newBudget = Budget(
      id: '',
      title: '',
      startDate: DateTime(2023),
      endDate: DateTime(2023),
      categories: []);

  Future<void> _selectDefaultExpensive(ctx, ex) async {
    var item =
        _expensiveDefaults.firstWhere((element) => element['key'] == ex['key']);
    var status = item['checked'] as bool;
    if (status) {
      setState(() {
        item['checked'] = !status;
      });
      return;
    }

    setState(() {
      var status = item['checked'] as bool;
      item['checked'] = !status;
    });

    myController.clear();
    final bool? isSave = await _enterAmount("", _getTransText(ctx, ex['key']));

    if (isSave == null || !isSave)
      setState(() {
        var status = item['checked'] as bool;
        item['checked'] = !status;
      });

    if (_cateExSelection.isEmpty) {
      _cateExSelection.add(Category(
          id: "",
          totalSpent: 0.0,
          description: _getTransText(ctx, ex['key']),
          type: 'expensive',
          iconData: ex['iconData'],
          volume: double.parse(myController.text)));
      return;
    }

    var index = -1;
    if (_cateExSelection.isEmpty) {
      index = _cateExSelection
          .indexWhere((c) => c.description == _getTransText(ctx, ex['key']));
    }

    if (index != -1) {
      _cateExSelection.removeAt(index);
    } else {
      _cateExSelection.add(Category(
          id: "",
          totalSpent: 0.0,
          description: _getTransText(ctx, ex['key']),
          iconData: ex['iconData'],
          type: 'expensive',
          volume: double.parse(myController.text)));
    }
  }

  Future<void> _selectDefaultIncome(ctx, income) async {
    var item = _incomeDefaults
        .firstWhere((element) => element['key'] == income['key']);
    if (item['checked'] as bool) {
      setState(() {
        bool status = item['checked'] as bool;
        item['checked'] = !status;
      });
      return;
    }

    setState(() {
      bool status = item['checked'] as bool;
      item['checked'] = !status;
    });

    myController.clear();
    final bool? isSave =
        await _enterAmount("text", _getTransText(ctx, income['key']));

    if (isSave == null || !isSave)
      setState(() {
        bool status = item['checked'] as bool;
        item['checked'] = !status;
      });

    if (_cateExSelection.isEmpty) {
      _cateExSelection.add(Category(
          id: "",
          totalSpent: 0.0,
          description: _getTransText(ctx, income['key']),
          iconData: income['iconData'],
          type: 'income',
          volume: double.parse(myController.text)));
      return;
    }

    var index = -1;
    if (_cateExSelection.isEmpty) {
      index = _cateExSelection.indexWhere(
          (c) => c.description == _getTransText(ctx, income['key']));
    }

    if (index != -1) {
      _cateExSelection.removeAt(index);
    } else {
      _cateExSelection.add(Category(
          id: "",
          totalSpent: 0.0,
          description: _getTransText(ctx, income['key']),
          iconData: income['iconData'],
          type: 'income',
          volume: double.parse(myController.text)));
    }
  }

  void _selectRange(RangeSelection r) {
    DateTime st, ed;
    switch (r) {
      case RangeSelection.THIS_MONTH:
        DateTime now = DateTime.now();
        st = new DateTime(now.year, now.month, 1);
        ed = new DateTime(now.year, now.month + 1, 0);
        break;
      case RangeSelection.THIS_WEEK:
        DateTime now = DateTime.now();
        int currentDay = now.weekday;
        st = now.subtract(Duration(days: currentDay - 1));
        ed = st.add(Duration(days: 6));
        break;
      case RangeSelection.THIS_DAY:
        DateTime now = DateTime.now();
        st = now;
        ed = now;
        break;
      case RangeSelection.NEXT_MONTH:
        DateTime now = DateTime.now();
        st = new DateTime(now.year, now.month + 1, 1);
        ed = new DateTime(now.year, now.month + 2, 0);
        break;
      case RangeSelection.NEXT_WEEK:
        DateTime now = DateTime.now();
        int next7Day = now.weekday - 7;
        st = now.subtract(Duration(days: next7Day - 1));
        ed = st.add(Duration(days: 6));
        break;
    }
    setState(() {
      _selection = r;
      _selectedStartDate = st;
      _selectedEndDate = ed;
    });
  }

  Future<bool?> _enterAmount(String text, String cateName) async {
    var title = text == ""
        ? '${AppLocalizations.of(context)!.budgetedAmount} $cateName'
        : '${AppLocalizations.of(context)!.incomeGoal}: $cateName';
    var label = text == "" ? '' : '${AppLocalizations.of(context)!.incomeGoal}';

    return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(title),
            contentPadding: EdgeInsets.symmetric(horizontal: 30),
            children: <Widget>[
              TextFormField(
                  decoration: InputDecoration(labelText: label),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  controller: myController,
                  autofocus: true),
              SimpleDialogOption(
//                onPressed: () { Navigator.pop(context, false); },
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text('OK'),
                ),
              ),
            ],
          );
        });
  }

  void _saveForm(BuildContext ctx) async {
    var isValidated = _form.currentState!.validate();
    if (!isValidated) return;

    var uuid = Uuid();

    List<Category> exCates = [];

    for (var item in _cateExSelection) {
      Category x = Category(
          id: uuid.v4(),
          description: item.description,
          type: item.type,
          volume: item.volume,
          iconData: item.iconData,
          totalSpent: 0.0);

      exCates.add(x);
    }

    _form.currentState!.save();
    _newBudget = Budget(
        id: uuid.v4(),
        categories: exCates,
        title: _newBudget.title,
        startDate: _selectedStartDate!,
        endDate: _selectedEndDate!);

    try {
      // Budget newB =
      //     await Provider.of<Budgets>(ctx, listen: false).addBudget(_newBudget);

      final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context)!.msgCreateBudgetSuccess));
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
      Navigator.of(ctx).pop();

      // Provider.of<Metadata>(ctx, listen: false).setCurrentBudget(newB.id);

      Box budgetsBox = Hive.box<Budget>('budgets');
      budgetsBox.put(_newBudget.id, _newBudget);
    } catch (error) {
      print(error);

      String message = AppLocalizations.of(context)!.msgCreateBudgetFailed;
      // if (error?.osError?.errorCode == 7)
      //   message = AppLocalizations.of(context)!.youAreOffline;

      final snackBar = SnackBar(content: Text(message));
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
    }
  }

  void _presentStartDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedStartDate!,
      firstDate: DateTime(2021),
      lastDate: DateTime(2051),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedStartDate = pickedDate;
      });
    });
  }

  void _presentEndDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedEndDate!,
      firstDate: DateTime(2021),
      lastDate: DateTime(2051),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedEndDate = pickedDate;
      });
    });
  }

  String _getTransText(BuildContext ctx, ex) {
    String tx = 'default';
    switch (ex) {
      case ExpensiveCategory.CHILDCARE:
        tx = AppLocalizations.of(context)!.childcare;
        break;
      case ExpensiveCategory.CLOTHING:
        tx = AppLocalizations.of(context)!.clothing;
        break;
      case ExpensiveCategory.EDUCATION:
        tx = AppLocalizations.of(context)!.education;
        break;
      case ExpensiveCategory.ENTERTAINMENT:
        tx = AppLocalizations.of(context)!.entertainment;
        break;
      case ExpensiveCategory.FOOD:
        tx = AppLocalizations.of(context)!.food;
        break;
      case ExpensiveCategory.HOUSING:
        tx = AppLocalizations.of(context)!.housing;
        break;
      case ExpensiveCategory.INSURANCE:
        tx = AppLocalizations.of(context)!.insurance;
        break;
      case ExpensiveCategory.MEDICAL_HEALTH_CARE:
        tx = AppLocalizations.of(context)!.medicalHealthCare;
        break;
      case ExpensiveCategory.UTILITIES:
        tx = AppLocalizations.of(context)!.utilities;
        break;
      case ExpensiveCategory.TRANSPORTATION:
        tx = AppLocalizations.of(context)!.transportation;
        break;
      default:
        if (ex == 'SALARY') tx = AppLocalizations.of(context)!.salary;
        if (ex == 'OTHERS') tx = AppLocalizations.of(context)!.otherIncome;
        break;
    }

    return tx;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _selectRange(_selection);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newBudget),
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
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  GestureDetector(
                    onTap: () => {_selectRange(RangeSelection.THIS_MONTH)},
                    child: Chip(
                      avatar: CircleAvatar(
                        child: _selection == RangeSelection.THIS_MONTH
                            ? Icon(Icons.check)
                            : null,
                      ),
                      label: Text(AppLocalizations.of(context)!.thisMonth),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {_selectRange(RangeSelection.THIS_WEEK)},
                    child: Chip(
                      avatar: CircleAvatar(
                        child: _selection == RangeSelection.THIS_WEEK
                            ? Icon(Icons.check)
                            : null,
                      ),
                      label: Text(AppLocalizations.of(context)!.thisWeek),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {_selectRange(RangeSelection.THIS_DAY)},
                    child: Chip(
                      avatar: CircleAvatar(
                        child: _selection == RangeSelection.THIS_DAY
                            ? Icon(Icons.check)
                            : null,
                      ),
                      label: Text(AppLocalizations.of(context)!.onlyToday),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {_selectRange(RangeSelection.NEXT_MONTH)},
                    child: Chip(
                      avatar: CircleAvatar(
                        child: _selection == RangeSelection.NEXT_MONTH
                            ? Icon(Icons.check)
                            : null,
                      ),
                      label: Text(AppLocalizations.of(context)!.nextMonth),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {_selectRange(RangeSelection.NEXT_WEEK)},
                    child: Chip(
                      avatar: CircleAvatar(
                        child: _selection == RangeSelection.NEXT_WEEK
                            ? Icon(Icons.check)
                            : null,
                      ),
                      label: Text(AppLocalizations.of(context)!.nextWeek),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    Text(AppLocalizations.of(context)!.startDate),
                    Container(
                      child: OutlinedButton(
                        child: Text(
                          _selectedStartDate == null
                              ? AppLocalizations.of(context)!.msgNoDateChosen
                              : '${DateFormat.yMd().format(_selectedStartDate!)}',
                        ),
                        onPressed: _presentStartDatePicker,
                      ),
                    ),
                  ]),
                  Column(
                    children: [
                      Text(AppLocalizations.of(context)!.endDate),
                      Container(
                        child: OutlinedButton(
                          child: Text(
                            _selectedEndDate == null
                                ? AppLocalizations.of(context)!.msgNoDateChosen
                                : '${DateFormat.yMd().format(_selectedEndDate!)}',
                          ),
                          onPressed: _presentEndDatePicker,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: ExpansionPanelList(
                  expansionCallback: (panelIndex, isExpanded) {
                    setState(() {
                      _activeExpensive = !_activeExpensive;
                    });
                  },
                  children: <ExpansionPanel>[
                    ExpansionPanel(
                        headerBuilder: (context, isExpanded) {
                          return Container(
                            alignment: Alignment.center,
                            child: Text(
                              AppLocalizations.of(context)!
                                  .addSomeCategoriesToThisBudget,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          );
                        },
                        body: Wrap(
                          spacing: 5.0,
                          runSpacing: 5.0,
                          children: [
                            for (var item in _expensiveDefaults)
                              GestureDetector(
                                onTap: () =>
                                    {_selectDefaultExpensive(context, item)},
                                child: Chip(
                                  backgroundColor: item['checked'] == true
                                      ? Theme.of(context)
                                          .chipTheme
                                          .backgroundColor
                                      : null,
                                  avatar: Icon(item['iconData'] as IconData?,
                                      color: item['checked'] == true
                                          ? Colors.amber[700]
                                          : Theme.of(context)
                                              .chipTheme
                                              .selectedColor),
                                  label: Text(
                                    _getTransText(context, item['key']),
                                    style: TextStyle(
                                        color: item['checked'] == true
                                            ? Colors.amber[700]
                                            : Theme.of(context)
                                                .chipTheme
                                                .checkmarkColor),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        isExpanded: _activeExpensive,
                        canTapOnHeader: true)
                  ],
                ),
              ),
              Divider(),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: ExpansionPanelList(
                  expansionCallback: (panelIndex, isExpanded) {
                    setState(() {
                      _activeIncome = !_activeIncome;
                    });
                  },
                  children: <ExpansionPanel>[
                    ExpansionPanel(
                        headerBuilder: (context, isExpanded) {
                          return Container(
                            alignment: Alignment.center,
                            child: Text(
                              AppLocalizations.of(context)!
                                  .addIncomesToThisBudget,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          );
                        },
                        body: Wrap(
                          spacing: 5.0,
                          runSpacing: 5.0,
                          alignment: WrapAlignment.start,
                          children: [
                            for (var item in _incomeDefaults)
                              GestureDetector(
                                onTap: () =>
                                    {_selectDefaultIncome(context, item)},
                                child: Chip(
                                  backgroundColor: item['checked'] == true
                                      ? Theme.of(context)
                                          .chipTheme
                                          .backgroundColor
                                      : null,
                                  avatar: Icon(item['iconData'] as IconData?,
                                      color: item['checked'] == true
                                          ? Colors.amber[700]
                                          : Theme.of(context)
                                              .chipTheme
                                              .selectedColor),
                                  label: Text(
                                    _getTransText(context, item['key']),
                                    style: TextStyle(
                                        color: item['checked'] == true
                                            ? Colors.amber[700]
                                            : Theme.of(context)
                                                .chipTheme
                                                .checkmarkColor),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        isExpanded: _activeIncome,
                        canTapOnHeader: true)
                  ],
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.youNeedABudgetName),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _newBudget = Budget(
                      title: value!,
                      id: "",
                      categories: [],
                      startDate: DateTime(2023),
                      endDate: DateTime(2023));
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () => {_saveForm(context)},
                child: Text(AppLocalizations.of(context)!.save),
              )
            ],
          ),
        ),
      ),
    );
  }
}
