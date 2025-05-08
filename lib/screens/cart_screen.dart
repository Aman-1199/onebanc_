import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartService = CartService();

  double cgst = 0;
  double sgst = 0;
  double grandTotal = 0;

  @override
  void initState() {
    super.initState();
    final subtotal = cartService.totalAmount;
    cgst = subtotal * 0.025;
    sgst = subtotal * 0.025;
    grandTotal = subtotal + cgst + sgst;
  }

  Future<void> placeOrder() async {
    try {
      final items = cartService.cart.values.toList();

      List<Map<String, dynamic>> requestData = items.map((cartItem) {
        return {
          "cuisine_id": 99999, // placeholder since we don't track this per item
          "item_id": int.tryParse(cartItem.item.id) ?? 0,
          "item_price": cartItem.item.price,
          "item_quantity": cartItem.quantity,
        };
      }).toList();

      final txnId = await ApiService.makePayment(
        totalAmount: grandTotal.toInt(),
        totalItems: items.fold(0, (sum, item) => sum + item.quantity),
        data: requestData,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Order Placed!"),
          content: Text("Transaction ID: $txnId"),
          actions: [
            TextButton(
              onPressed: () {
                cartService.clearCart();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // go back to home
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = cartService.cart;

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Cart")),
        body: const Center(child: Text("Cart is empty")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: cart.values.map((cartItem) {
                return ListTile(
                  leading: Image.network(cartItem.item.imageUrl, width: 50),
                  title: Text(cartItem.item.name),
                  subtitle: Text(
                      "₹${cartItem.item.price} × ${cartItem.quantity} = ₹${cartItem.item.price * cartItem.quantity}"),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                summaryRow("Subtotal", cartService.totalAmount),
                summaryRow("CGST (2.5%)", cgst),
                summaryRow("SGST (2.5%)", sgst),
                const SizedBox(height: 8),
                summaryRow("Grand Total", grandTotal, isBold: true),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: placeOrder,
                  child: const Text("Place Order"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryRow(String title, double value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text("₹${value.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
