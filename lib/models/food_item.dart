class FoodItem {
  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final double rating;
  final String? cuisineId;

  FoodItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    this.cuisineId,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'].toString(),
      name: json['name'],
      imageUrl: json['image_url'],
      price: int.parse(json['price'].toString()),
      rating: double.parse(json['rating'].toString()),
    );
  }
}