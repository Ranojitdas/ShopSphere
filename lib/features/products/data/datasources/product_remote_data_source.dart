import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/product_page_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductPageModel> getProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  });

  Future<ProductModel> getProductById(int id);

  Future<ProductPageModel> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  });

  Future<List<CategoryModel>> getCategories();

  Future<ProductPageModel> getProductsByCategory({
    required String categorySlug,
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  });
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProductPageModel> getProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'skip': skip,
    };
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }
    if (order != null && order.isNotEmpty) {
      queryParams['order'] = order;
    }

    final response = await dio.get(
      ApiEndpoints.products,
      queryParameters: queryParams,
    );

    return ProductPageModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await dio.get(
      ApiEndpoints.productDetails(id),
    );

    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductPageModel> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    final response = await dio.get(
      ApiEndpoints.productSearch,
      queryParameters: {
        'q': query,
        'limit': limit,
        'skip': skip,
      },
    );

    return ProductPageModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dio.get(
      ApiEndpoints.productCategories,
    );

    final rawList = response.data as List<dynamic>;
    return rawList.map((e) => CategoryModel.fromJson(e)).toList();
  }

  @override
  Future<ProductPageModel> getProductsByCategory({
    required String categorySlug,
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'skip': skip,
    };
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }
    if (order != null && order.isNotEmpty) {
      queryParams['order'] = order;
    }

    final response = await dio.get(
      ApiEndpoints.productsByCategory(categorySlug),
      queryParameters: queryParams,
    );

    return ProductPageModel.fromJson(response.data as Map<String, dynamic>);
  }
}
