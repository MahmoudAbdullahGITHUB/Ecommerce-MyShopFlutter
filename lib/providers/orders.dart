import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String authToken;
  String userId;

  getData(String authTok, String uId, List<OrderItem> orders) {
    authToken = authTok;
    userId = uId;
    _orders = orders;
    notifyListeners();
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    // the filterByUser parameter is an optional parameter that not have to pass it when call the function

    final url =
        'https://shop-77d24-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';

    try {
      final res = await http.get(url);

      ///in the Map >> the value of the Key is dynamic always i think witch mean that i don not know the value coming
      final extractedData = json.decode(res.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      final List<OrderItem> loadedOrders = [];

      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
              id: orderId,
              amount: orderData['title'],
              dateTime: DateTime.parse(orderData['dateTime']),
              products: (orderData['products'] as List<dynamic>)
                  .map((item) => CartItem(
                        id: item['id'],
                        price: item['price'],
                        quantity: item['quantity'],
                        title: item['price'],
                      ))
                  .toList()),
        );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    final url =
        'https://shop-77d24-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';

    try {
      final timeStamp = DateTime.now();
      final res = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProduct
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
          }));

      _orders.insert(
          0,
          OrderItem(
            id: json.decode(res.body)['name'],
            amount: total,
            dateTime: timeStamp,
            products: cartProduct,
          ));
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
