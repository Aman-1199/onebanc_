import '../models/food_item.dart';

class CartItem {
  final FoodItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});
}

class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final Map<String, CartItem> _cart = {};

  void addToCart(FoodItem item) {
    if (_cart.containsKey(item.id)) {
      _cart[item.id]!.quantity += 1;
    } else {
      _cart[item.id] = CartItem(item: item);
    }
  }

  Map<String, CartItem> get cart => _cart;

  void clearCart() {
    _cart.clear();
  }

  double get totalAmount {
    return _cart.values.fold(0, (sum, item) => sum + item.item.price * item.quantity);
  }
}
