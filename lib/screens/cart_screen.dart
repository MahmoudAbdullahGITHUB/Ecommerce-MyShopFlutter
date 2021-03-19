import 'package:flutter/material.dart';
import 'package:my_shop_flutter_app/providers/orders.dart';
import 'package:my_shop_flutter_app/widgets/cart_item.dart';
import 'package:provider/provider.dart';

/// note that i make show only for the Cart that exist on the below path
import '../providers/cart.dart' show Cart;

class CartScreen extends StatelessWidget {
  static const routName = "/cart";

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("CartScreen"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),

                  /// this spacer() to make the coming widget ( in our case is chip ) take all available space
                  Spacer(),

                  /// this chip only like container
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(color: Theme.of(context).primaryTextTheme.headline6.color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(
                    cart: cart,
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
              child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, int index) =>

                      /// note that this CartItem() witch exist in widgets folder not that one on cart() class on the providers folder
                      CartItem(
                        cart.items.values.toList()[index].id,

                        /// note here that i used item.keys not item.values because the keys are the productsId;
                        cart.items.keys.toList()[index],
                        cart.items.values.toList()[index].price,
                        cart.items.values.toList()[index].quantity,
                        cart.items.values.toList()[index].title,
                      )))
        ],
      ),
    );
  }
}

/// why i separated OrderButton on another class
class OrderButton extends StatefulWidget {
  final Cart cart;

  const OrderButton({
    @required this.cart,
  });

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('Order Now'),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              /// i think that i made this setState because all screen will change so no problem
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                widget.cart.items.values.toList(),
                widget.cart.totalAmount,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
