import 'package:flutter/material.dart';
import '../models/cuisine.dart';
import '../models/food_item.dart';
import '../services/cart_service.dart';

class CuisineScreen extends StatefulWidget {
  final Cuisine cuisine;

  const CuisineScreen({super.key, required this.cuisine});

  @override
  State<CuisineScreen> createState() => _CuisineScreenState();
}

class _CuisineScreenState extends State<CuisineScreen> {
  final CartService cartService = CartService();

  void addToCart(FoodItem item) {
    setState(() {
      cartService.addToCart(item, cuisineId: widget.cuisine.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} added to cart')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dishes = widget.cuisine.items;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.cuisine.name,
          style: TextStyle(
            fontSize: 25,
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),),
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color of the back arrow
        ),
      ),
      body: ListView.builder(
        itemCount: dishes.length,
        itemBuilder: (context, index) {
          final dish = dishes[index];
          return SizedBox(
            height: 80,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: Image.network(dish.imageUrl, width: 60),
                title: Text(dish.name),
                subtitle: Text('₹${dish.price} | Rating: ${dish.rating}'),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => addToCart(dish),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
