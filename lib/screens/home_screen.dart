import 'package:flutter/material.dart';
import '../models/cuisine.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';
import 'cuisine_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isHindi;
  final VoidCallback onLanguageToggle;

  const HomeScreen({super.key, required this.isHindi, required this.onLanguageToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Cuisine> cuisines = [];
  List<FoodItem> topDishes = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      final data = await ApiService.getItemList();
      setState(() {
        cuisines = data;
        topDishes = data.expand((cuisine) => cuisine.items).take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.isHindi;
    return Scaffold(
      appBar: AppBar(
        title: Text(lang ? 'रेस्टोरेंट ऐप' : 'Restaurant App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: widget.onLanguageToggle,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Segment 1: Cuisine List
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cuisines.length,
              itemBuilder: (context, index) {
                final cuisine = cuisines[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CuisineScreen(cuisine: cuisine),
                      ),
                    );
                  },
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(cuisine.imageUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cuisine.name,
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),

          // Segment 2: Top 3 Dishes
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                lang ? 'शीर्ष 3 व्यंजन' : 'Top 3 Dishes',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: topDishes.length,
              itemBuilder: (context, index) {
                final dish = topDishes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Image.network(dish.imageUrl, width: 60, fit: BoxFit.cover),
                    title: Text(dish.name),
                    subtitle: Text(
                      '${lang ? 'मूल्य' : 'Price'}: ₹${dish.price} | ${lang ? 'रेटिंग' : 'Rating'}: ${dish.rating}',
                    ),
                    trailing: const Icon(Icons.add),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
        },
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
