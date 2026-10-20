import '../../domain/entities/product_entity.dart';
import 'product_review_model.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    required super.tags,
    super.brand,
    super.sku,
    super.weight,
    super.warrantyInformation,
    super.shippingInformation,
    super.availabilityStatus,
    super.reviews = const [],
    super.returnPolicy,
    super.minimumOrderQuantity,
    super.images = const [],
    required super.thumbnail,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawReviews = json['reviews'] as List<dynamic>? ?? [];
    final reviews = rawReviews
        .map((e) => ProductReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final rawTags = json['tags'] as List<dynamic>? ?? [];
    final tags = rawTags.map((e) => e.toString()).toList();

    final rawImages = json['images'] as List<dynamic>? ?? [];
    final images = rawImages.map((e) => e.toString()).toList();

    final thumbnail = json['thumbnail'] as String? ?? (images.isNotEmpty ? images.first : '');

    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      tags: tags,
      brand: json['brand'] as String?,
      sku: json['sku'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      warrantyInformation: json['warrantyInformation'] as String?,
      shippingInformation: json['shippingInformation'] as String?,
      availabilityStatus: json['availabilityStatus'] as String?,
      reviews: reviews,
      returnPolicy: json['returnPolicy'] as String?,
      minimumOrderQuantity: (json['minimumOrderQuantity'] as num?)?.toInt(),
      images: images,
      thumbnail: thumbnail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'tags': tags,
      'brand': brand,
      'sku': sku,
      'weight': weight,
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'availabilityStatus': availabilityStatus,
      'reviews': reviews.map((e) => (e as ProductReviewModel).toJson()).toList(),
      'returnPolicy': returnPolicy,
      'minimumOrderQuantity': minimumOrderQuantity,
      'images': images,
      'thumbnail': thumbnail,
    };
  }
}
