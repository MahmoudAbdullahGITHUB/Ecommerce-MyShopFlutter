import 'package:flutter/material.dart';
import 'package:my_shop_flutter_app/widgets/order_item.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;

class OrderScreen extends StatelessWidget {
  static const routName = "/order";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Order'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            if (snapshot.error != null) {
              print('your error = ${snapshot.error.toString()}');
              return Center(child: Text('An error occurred!'));
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (BuildContext context, int index) =>
                        OrderItem(orderData.orders[index])),
              );
            }
          }
        },
      ),
    );
  }
}
