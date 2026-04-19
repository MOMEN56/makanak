class ProductModel {
  const ProductModel({
    required this.imageUrl,
    required this.name,
    required this.price,
    this.desc = '',
  });

  final String imageUrl;
  final String name;
  final String price;
  final String desc;
}
