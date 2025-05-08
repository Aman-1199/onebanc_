import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';
import 'dart:convert'; // Ensure this is included

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
          "cuisine_id": int.tryParse(cartItem.cuisineId) ?? 0,
          "item_id": int.tryParse(cartItem.item.id) ?? 0,
          "item_price": cartItem.item.price,
          "item_quantity": cartItem.quantity,
        };
      }).toList();

      final totalAmount = grandTotal.toInt();
      final totalItems = items.fold(0, (sum, item) => sum + item.quantity);

      // Ensure you're using jsonEncode properly
      print("🧾 Sending payment payload:");
      print(jsonEncode({
        "total_amount": totalAmount,
        "total_items": totalItems,
        "data": requestData
      }));

      final txnId = await ApiService.makePayment(
        totalAmount: totalAmount,
        totalItems: totalItems,
        data: requestData,
      );

      // ✅ Show success toast/snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Payment completed successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // ✅ Show confirmation dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Order Placed Successfully ✅"),
          content: Text("Your transaction has been completed.\n\nTransaction ID:\n$txnId"),
          actions: [
            TextButton(
              onPressed: () {
                cartService.clearCart();
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to home screen
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("❌ Payment failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Payment Failed: $e"),
          backgroundColor: Colors.red,
        ),
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
                    "₹${cartItem.item.price} × ${cartItem.quantity} = ₹${cartItem.item.price * cartItem.quantity}",
                  ),
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
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          "₹${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
