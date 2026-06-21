import 'package:dio/dio.dart';
import 'package:e_commerce_product/models/RespProducts.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://dummyjson.com",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true
      )
    );
  }

  Future<List<Products>?> fetchData() async {
    try{
      var response=await _dio.get("/products");
      if(response.statusCode==200){
        var respProducts= RespProducts.fromJson(response.data);
        return respProducts.products;
      }
    }
    on DioException catch(e){
      print(e.error.toString());
    }
    catch(e){
      print(e);
    }
    return null;
  }

}