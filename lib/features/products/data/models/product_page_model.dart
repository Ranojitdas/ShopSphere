import '../../domain/entities/product_page_entity.dart';
import 'product_model.dart';

class ProductPageModel extends ProductPageEntity {
  const ProductPageModel({
    required super.products,
    required super.total,
    required super.skip,
    required super.limit,
  });

  factory ProductPageModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['products'] as List<dynamic>? ?? [];
    final products = rawList
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return ProductPageModel(
      products: products,
      total: (json['total'] as num?)?.toInt() ?? products.length,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? products.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((e) => (e as ProductModel).toJson()).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }
}
