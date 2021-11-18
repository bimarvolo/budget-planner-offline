import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_budget_frontend/app_constant.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../providers/metadata.dart';
import '../providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(115, 117, 255, 1).withOpacity(0.3),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-20 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade400,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],

                      ),
                      child:
                      Text(
                        AppLocalizations.of(context).budgetPlaner,
                        style: TextStyle(
                          // color: Theme.of(context).accentTextTheme.title.color,
                          fontSize: 35,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  var _isShowPwd = false;
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  GoogleSignIn _googleSignIn;

  void _changePwdMode() {
    setState(() {
      _isShowPwd = !_isShowPwd;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(context).errorMessage),
            content: Text(message),
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

  Future<void> _submit(ctx) async {

    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );

        Auth auth = Provider.of<Auth>(context, listen: false);
        Metadata meta = auth.metadata;
        Provider.of<Metadata>(context, listen: false).setAuth(auth.userId, auth.token);
        Provider.of<Metadata>(context, listen: false).syncMetadata(meta.language, meta.currency, meta.currentBudget, meta.themeMode);
      } else {
        // Sign user up
          await Provider.of<Auth>(context, listen: false).signup(
            _authData['email'],
            _authData['password'],
        );

        final snackBar = SnackBar(content: Text(AppLocalizations.of(context).loginSuccess));
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);

        // auto login after signup
        _switchAuthMode();
          await _submit(context);
      }
    } on SocketException catch (error) {
      var errorMessage = AppLocalizations.of(context).authenticationFailed;

      if(error != null && error.osError != null)
        errorMessage = error.osError.message;

      _showErrorDialog(errorMessage);
    } catch (error) {
      print(error);
      var errorMessage = AppLocalizations.of(context).couldNotAuthenticate;

      if(error is String) {
        _showErrorDialog(error is String ? error : errorMessage);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleGoogleSignIn(ctx) async {
    try {
      final result = await _googleSignIn.signIn();
      final ggAuth = await result.authentication;
      print(ggAuth.idToken);
      print(ggAuth.accessToken);

      if(result == null) {
        final snackBar3 = SnackBar(content: Text("Sign in google error"));
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar3);
      } else {
        bool isExisted = await Provider.of<Auth>(context, listen: false).loginWithGoogle(result.email);

        if(isExisted) {
          Auth auth = Provider.of<Auth>(context, listen: false);
          Metadata meta = auth.metadata;
          Provider.of<Metadata>(context, listen: false).setAuth(auth.userId, auth.token);
          Provider.of<Metadata>(context, listen: false).syncMetadata(meta.language, meta.currency, meta.currentBudget, meta.themeMode);
        } else {
          _emailController.text = result.email;
          _passwordController.text = 'Budget@423';
          _submit(context);
        }
      }
    } catch (error) {
      print(error);
      final snackBar3 = SnackBar(content: Text("Sign in google error"));
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar3);
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  void initState() {
    _googleSignIn = GoogleSignIn(
      clientId: AppConst.FIREBASE_CLIENT_ID,
      scopes: [
        'email'
      ],
    );
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        height: _authMode == AuthMode.Signup ? 320 : 460,
        duration: Duration(milliseconds: 1000),
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 460),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).email,
                  ),
                  keyboardType: TextInputType.emailAddress,
            controller: _emailController,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return AppLocalizations.of(context).invalidEmail;
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).password,
                      suffixIcon: GestureDetector(
                        onTap: _changePwdMode,
                          child: Icon(_isShowPwd ? Icons.visibility_off_rounded : Icons.remove_red_eye_rounded)),
                  ),
                  obscureText: !_isShowPwd,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return AppLocalizations.of(context).passwordIsTooShort;
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).confirmPassword),
                    obscureText: !_isShowPwd,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return AppLocalizations.of(context).passwordsDoNotMatch;
                            }
                            return null;
                          }
                        : null,
                  ),

                // SizedBox(
                //   height: 20,
                // ),
                // IconButton(icon: Icon(Icons.bug_report), onPressed: () => {
                //   _emailController.text = 'vinh2304@gmail.com',
                //   _passwordController.text = 'enove214',
                //   _submit(context)
                // },),

                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator(),
                if (!_isLoading)
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? AppLocalizations.of(context).login : AppLocalizations.of(context).signup),
                    onPressed: () => _submit(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child:
                  Text(
                    '${_authMode == AuthMode.Login ? AppLocalizations.of(context).signup : AppLocalizations.of(context).loginInstead}',
                    style: TextStyle(color: Theme.of(context).primaryTextTheme.button.color),
                  ),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),

                SizedBox(
                  height: 40,
                ),
                Divider(),
                if (_isLoading && _authMode != AuthMode.Login)
                  CircularProgressIndicator(),
                if (_authMode == AuthMode.Login)
                  RaisedButton(
                    child:
                    Text(AppLocalizations.of(context).signInWithGoogle),
                    onPressed: () => _handleGoogleSignIn(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                    EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
