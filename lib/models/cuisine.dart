import 'food_item.dart';

class Cuisine {
  final String id;
  final String name;
  final String imageUrl;
  final List<FoodItem> items;

  Cuisine({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.items,
  });

  factory Cuisine.fromJson(Map<String, dynamic> json) {
    List<FoodItem> dishes = [];
    if (json['items'] != null) {
      dishes = (json['items'] as List)
          .map((item) => FoodItem.fromJson(item))
          .toList();
    }

    return Cuisine(
      id: json['cuisine_id'].toString(),
      name: json['cuisine_name'],
      imageUrl: json['cuisine_image_url'],
      items: dishes,
    );
  }
}
