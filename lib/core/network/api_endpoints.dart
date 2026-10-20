class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://dummyjson.com';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String refresh = '/auth/refresh';

  static const String products = '/products';
  static const String productSearch = '/products/search';
  static const String productCategories = '/products/categories';
  static const String categoryProducts = '/products/category';

  static String productDetails(int id) => '/products/$id';
  static String productsByCategory(String category) => '/products/category/$category';

  static const String addCart = '/carts/add';
  static const String userCarts = '/carts/user';

  static const String simulate500 = '/http/500';
  static const String simulate404 = '/http/404';
}
