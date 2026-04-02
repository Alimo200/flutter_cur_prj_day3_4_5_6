import 'package:flutter/material.dart';
import '../api/api_client.dart';

class ProductProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<String> categories = ["All Products"];
  bool isLoadingCategories = true;

  Future<void> fetchCategories() async {
    isLoadingCategories = true;
    notifyListeners();

    try {
      var res = await _apiClient.getData('/products/categories');
      if (res.statusCode == 200) {
        List<String> fetchedCategories = [];
        for (var item in res.data) {
          if (item is String) {
            fetchedCategories.add(item);
          } else if (item is Map) {
            fetchedCategories.add(item['slug'] ?? item['name'] ?? '');
          }
        }
        categories = ["All Products", ...fetchedCategories];
      }
    } catch (e) {
      print(e);
    }

    isLoadingCategories = false;
    notifyListeners();
  }
}