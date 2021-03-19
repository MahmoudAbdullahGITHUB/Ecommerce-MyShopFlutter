import 'package:flutter/material.dart';
import 'package:my_shop_flutter_app/models/http_exception.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Auth extends ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  /// here
  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now()) && _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBWoe60etCI208SZfC4XHKjBZ8pO5I-HJA';

    final res = await http.post(url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }));
    final responseData = json.decode(res.body);
    if (responseData['error'] != null) {
      print('ma http ${HttpException(responseData['error']['message'])}');
      throw HttpException(responseData['error']['message']);
    }
    _token = responseData['idToken'];
    _userId = responseData['localId'];
    _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
    _autoLogout();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String userData = json
        .encode({'token': _token, 'userId': _userId, 'expiryDate': _expiryDate.toIso8601String()});
    prefs.setString('userData', userData);

    try {} catch (error) {
      throw error.toString();
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final Map<String, Object> extractedData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    final expireDate = DateTime.parse(extractedData['expiryDate']);
    if (expireDate.isBefore(DateTime.now())) return false;

    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiryDate = expireDate;

    /// why not put notifyListeners at the end of the code
    notifyListeners();

    /// wyh this function used here
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
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
