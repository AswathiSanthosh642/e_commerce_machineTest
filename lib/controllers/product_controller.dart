import 'package:dio/dio.dart';
import 'package:e_commerce_product/services/api_service.dart';
import 'package:flutter/cupertino.dart';

import '../models/RespProducts.dart';

class ProductController extends ChangeNotifier{

  ApiService apiService=ApiService();

  bool isLoading=false;

  List<Products>? productsList=[];

  Future<void> getAllProducts() async {
      isLoading=true;
      notifyListeners();
      productsList = await apiService.fetchData();
      isLoading=false;
      notifyListeners();
  }


}