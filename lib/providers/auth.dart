import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import './metadata.dart';
import '../app_constant.dart';

class Auth with ChangeNotifier {
  DateTime _expiryDate;
 String _token;
 String _userId;
 String _email;
 Metadata _metadata;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  String get email {
    return _email;
  }

  Metadata get metadata {
    return _metadata;
  }

  String get currentBudget {
    return _metadata?.currentBudget;
  }

  Future<void> _authenticate(
      String email, String password) async {

    final url = '${AppConst.BASE_URL}/user/login';
    final Uri uri = Uri.parse(url);
    try {
      final response = await http.post(
        uri,
        body: json.encode(
          {
            'email': email,
            'password': password
          },
        ),
      );

      await _saveLoginData(response);
    } catch (error) {
      throw error;
    }
  }

  _saveLoginData(response) async {
    final responseData = json.decode(response.body);
    if (responseData['error'] != null) {
      if(responseData['error'] is String) {
        throw responseData['error'];
      }

      if (responseData['error']['description'] != null) {
        throw responseData['error']['description'];
      }
    }
    _token = 'Bearer ${responseData['token']}';
    _userId = responseData['data']['id'];
    _email = responseData['data']['email'];
    var meta = responseData['data']['metadata'];
    if (meta == null) {
      _metadata = new Metadata(
          token: _token,
          userId: _userId,
          currentBudget: null,
          currency: '\$',
          themeMode: 'AUTO',
          language: 'en');
    } else {
      _metadata = new Metadata(
          token: _token,
          userId: _userId,
          currentBudget: meta['currentBudget'],
          currency: meta['currency'] != null ? meta['currency'] : '\$',
          themeMode: meta['themeMode'] != null ? meta['themeMode'] : 'AUTO',
          language: meta['language'] != null ? meta['language'] : 'en');
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode(
      {
        'token': _token,
        'userId': _userId,
        'metadata': _metadata,
      },
    );
    prefs.setString('userData', userData);
  }

  Future<void> _signup(
      String email, String password) async {

    final uri = Uri.parse('${AppConst.BASE_URL}/user/register');
    try {
      final response = await http.post(
        uri,
        body: json.encode(
          {
            "email": email,
            "password": password
          },
        ),
      );

    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _signup(email, password);
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password);
  }

  Future<bool> loginWithGoogle(String email) async {
    bool isExisted = false;
    final url = '${AppConst.BASE_URL}/user/login';
    final Uri uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: json.encode(
        {'email': email, 'password': "Budget@423"},
      ),
    );

    final spData = json.decode(response.body);
    if (spData['error'] != null) {
      if(spData['error'] is String) {
        await signup(email, "Budget@423");
      } else if (spData['error']['description'] != null) {
        await signup(email, "Budget@423");
      }
    } else {
      isExisted = true;
      await _saveLoginData(response);
    }

    return isExisted;
  }

  Future<bool> tryAutoLogin() async {

    print('tryAutoLogin');

    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      print('tryAutoLogin return false');
      return false;
    }

    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    var meta = Map<String, String>.from(extractedUserData['metadata']);

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _metadata = new Metadata(
        currentBudget: meta["currentBudget"],
        language: meta["language"],
        currency: meta["currency"],
        themeMode: meta["themeMode"]
    );

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _metadata = new Metadata();
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
