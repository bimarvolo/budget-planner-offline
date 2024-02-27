import 'package:flutter/material.dart';

import 'package:money_budget_frontend_offile/hive/metadata_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum EAppTheme { AUTO, LIGHT, DART }

class Language {
  String? code;
  String? name;

  Language({this.code, this.name});
}

class Currency {
  String? code;
  String? name;
  Icon? icon;

  Currency({this.code, this.name, this.icon});
}

class Account extends StatefulWidget {
  static const routeName = '/account';

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  EAppTheme _currentTheme = EAppTheme.AUTO;

  List<Language> _langs = [
    new Language(code: 'en', name: 'English'),
    new Language(code: 'vi', name: 'Vietnam'),
    new Language(code: 'fr', name: 'France'),
    new Language(code: 'de', name: 'Germany'),
    new Language(code: 'es', name: 'Spain'),
    new Language(code: 'pt', name: 'Portugal'),
  ];
  Language? _languageSelected;

  List<Currency> _curencies = [
    new Currency(code: '\$', name: 'USD'),
    new Currency(code: '€', name: 'Euro'),
    new Currency(code: '₫', name: 'Vietnamese Dong'),
    new Currency(code: '£', name: 'Pound'),
    new Currency(code: '¥', name: 'Yen'),
    new Currency(code: '₹', name: 'Indian Rupee'),
    new Currency(code: '₱', name: 'Philippine Peso'),
    new Currency(code: '₩', name: 'South Korean Won'),
    new Currency(code: '₪', name: 'Israeli New Shekel'),
    new Currency(code: '₦', name: 'Nigerian Naira'),
  ];
  Currency? _cuSelected;

  void _onSelectTheme(EAppTheme? theme) {
    setState(() {
      _currentTheme = theme!;
    });
    var themName = 'DART';
    if (_currentTheme == EAppTheme.AUTO) themName = 'AUTO';
    if (_currentTheme == EAppTheme.LIGHT) themName = 'LIGHT';

    MetadataStorage.storeTheme(themName);
  }

  _onSelectLang(Language? lang) {
    setState(() {
      _languageSelected = lang;
    });

    MetadataStorage.storeLang(_languageSelected!.code!);
  }

  _onSelectCurrency(Currency? cu) {
    setState(() {
      _cuSelected = cu;
    });
    MetadataStorage.storeCurrency(_cuSelected!.code!);
  }

  _getFlag(lang, ctx) {
    String path = '';
    switch (lang) {
      case 'en':
        path = 'assets/flags/english_flag.png';
        break;
      case 'fr':
        path = 'assets/flags/france_flag.png';
        break;
      case 'vi':
        path = 'assets/flags/vietnam_flag.png';
        break;
      case 'de':
        path = 'assets/flags/germany_flag.png';
        break;
      case 'es':
        path = 'assets/flags/spain_flag.png';
        break;
      case 'pt':
        path = 'assets/flags/portugal_flag.png';
        break;
      default:
        break;
    }
    return new Image.asset(path);
  }

  @override
  Widget build(BuildContext context) {
    var metadata = MetadataStorage.getMetadata();

    if (metadata != null) {
      _languageSelected =
          _langs.firstWhere((element) => element.code == metadata.lang);

      _cuSelected =
          _curencies.firstWhere((element) => element.code == metadata.currency);

      _currentTheme = EAppTheme.DART;

      if (metadata.theme == 'AUTO') _currentTheme = EAppTheme.AUTO;
      if (metadata.theme == 'LIGHT') _currentTheme = EAppTheme.LIGHT;
    }

    return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text('${AppLocalizations.of(context)!.account} ${user.email}'),
                // SizedBox(
                //   height: 10,
                // ),
                Text('${AppLocalizations.of(context)!.appearances}'),
                RadioListTile<EAppTheme>(
                  title: Text(AppLocalizations.of(context)!.dartMode),
                  value: EAppTheme.DART,
                  groupValue: _currentTheme,
                  onChanged: _onSelectTheme,
                ),
                RadioListTile<EAppTheme>(
                    title: Text(AppLocalizations.of(context)!.lightMode),
                    value: EAppTheme.LIGHT,
                    groupValue: _currentTheme,
                    onChanged: _onSelectTheme),
                RadioListTile<EAppTheme>(
                    title:
                        Text(AppLocalizations.of(context)!.useDeviceSettings),
                    subtitle: Text(AppLocalizations.of(context)!
                        .useDeviceSettingsDescription),
                    value: EAppTheme.AUTO,
                    groupValue: _currentTheme,
                    onChanged: _onSelectTheme),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)!.language),
                    Expanded(
                      child: DropdownButton<Language>(
                        isExpanded: true,
                        value: _languageSelected,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        // underline: Container(
                        //   height: 2,
                        //   color: Colors.deepPurpleAccent,
                        // ),
                        onChanged: _onSelectLang,
                        items: _langs
                            .map<DropdownMenuItem<Language>>((Language value) {
                          return DropdownMenuItem<Language>(
                            value: value,
                            child: Row(
                              children: [
                                _getFlag(value.code, context),
                                Text(' ${value.name}'),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)!.currency),
                    Expanded(
                      child: DropdownButton<Currency>(
                        isExpanded: true,
                        value: _cuSelected,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        // underline: Container(
                        //   height: 2,
                        //   color: Colors.deepPurpleAccent,
                        // ),
                        onChanged: _onSelectCurrency,
                        items: _curencies
                            .map<DropdownMenuItem<Currency>>((Currency value) {
                          return DropdownMenuItem<Currency>(
                            value: value,
                            child: Text('${value.name} (${value.code})'),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Text(AppLocalizations.of(context)!.aboutUs),
                SizedBox(
                  height: 5,
                ),
                Text('${AppLocalizations.of(context)!.contact} Vin XO'),
                SizedBox(
                  height: 5,
                ),
                Text(
                    '${AppLocalizations.of(context)!.email}: vinhpx.dev@gmail.com'),
              ],
            ),
          ],
        ));
  }
}
