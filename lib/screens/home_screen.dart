import 'package:flutter/material.dart';
import '../models/cuisine.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';
import 'cuisine_screen.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  final CartService cartService = CartService();

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
        topDishes = data.expand((cuisine) => cuisine.items.map((item) => FoodItem(
          id: item.id,
          name: item.name,
          imageUrl: item.imageUrl,
          price: item.price,
          rating: item.rating,
          cuisineId: cuisine.id,
        ))).take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  void addToCart(FoodItem item) {
    setState(() {
      cartService.addToCart(item, cuisineId: item.cuisineId!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} added to cart')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.isHindi;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(lang ? 'ज़ेस्टी बाइट्स' : 'ZestyBite',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontFamily: "Poppins",
          fontWeight: FontWeight.bold,
          fontSize: 35,

        ),),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.language,color: Colors.white,size: 25,),
            onPressed: widget.onLanguageToggle,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SizedBox(height: 50,),
          // Segment 1: Cuisine List
          CarouselSlider(
            options: CarouselOptions(
              height: 180,
              enlargeCenterPage: true,
              viewportFraction: 0.7, // Controls padding on left/right
              enableInfiniteScroll: true,
              autoPlay: false,
            ),
            items: cuisines.map((cuisine) {
              return Builder(
                builder: (BuildContext context) {
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
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(cuisine.imageUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.4),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cuisine.name,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),

          SizedBox(height: 35,),
          // Segment 2: Top 3 Dishes
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                lang ? 'शीर्ष 3 व्यंजन' : 'Top 3 Dishes',
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold,fontFamily: "Poppins",color: Colors.white ),
              ),
            ),
          ),

          SizedBox(height: 20,),

          Expanded(
            child: ListView.builder(
              itemCount: topDishes.length,
              itemBuilder: (context, index) {
                final dish = topDishes[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Set the border radius here
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: SizedBox(
                    height: 100,
                    child: ListTile(

                      leading: Image.network(dish.imageUrl, width: 70,height: 80, fit: BoxFit.cover),
                      title: Text(dish.name,
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                        ),),
                      subtitle: Text(
                        '${lang ? 'मूल्य' : 'Price'}: ₹${dish.price} | ${lang ? 'रेटिंग' : 'Rating'}: ${dish.rating}',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => addToCart(dish),
                      ),
                    ),
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