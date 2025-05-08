import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cuisine.dart';

class ApiService {
  static const String baseUrl = 'https://uat.onebanc.ai';

  static const Map<String, String> baseHeaders = {
    "X-Partner-API-Key": "uonebancservceemultrS3cg8RaL30",
    "Content-Type": "application/json"
  };

  // ✅ API: get_item_list
  static Future<List<Cuisine>> getItemList() async {
    final url = Uri.parse('$baseUrl/emulator/interview/get_item_list');
    final headers = {
      ...baseHeaders,
      "X-Forward-Proxy-Action": "get_item_list"
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"page": 1, "count": 10}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List cuisines = data['cuisines'];
      return cuisines.map((e) => Cuisine.fromJson(e)).toList();
    } else {
      print("❌ Failed to load item list: ${response.body}");
      throw Exception('Failed to load cuisines');
    }
  }

  // ✅ API: make_payment
  static Future<String> makePayment({
    required int totalAmount,
    required int totalItems,
    required List<Map<String, dynamic>> data,
  }) async {
    final url = Uri.parse('$baseUrl/emulator/interview/make_payment');
    final headers = {
      ...baseHeaders,
      "X-Forward-Proxy-Action": "make_payment"
    };

    final body = {
      "total_amount": totalAmount.toString(),
      "total_items": totalItems,
      "data": data,
    };

    print("📦 Sending payment request:");
    print(jsonEncode(body));

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    print("📥 Payment API response (${response.statusCode}):");
    print(response.body);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['txn_ref_no'];
    } else {
      throw Exception("Payment failed");
    }
  }
}
