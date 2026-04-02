import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../models/login_models.dart'; 

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  UserModel? userModel;
  bool isLoading = false;

  Future<void> loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("userData");
    
    if (data != null) {
      dynamic decodedData = jsonDecode(data);
      userModel = UserModel.fromJson(decodedData);
      notifyListeners();
    } else {
      userModel = null;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners(); 

    try {
      final response = await _apiClient.postData('/auth/login', {
        'username': email, 
        'password': password,
      });

      if (response.statusCode == 200 && response.data != null) {
        userModel = UserModel.fromJson(response.data);
        
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("userData", jsonEncode(response.data));

        isLoading = false;
        notifyListeners();
        return true; 
      }
    } catch (e) {
      print("Login Error: $e");
    }

    isLoading = false;
    notifyListeners();
    return false; 
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("userData"); 
    userModel = null;
    notifyListeners();
  }
}