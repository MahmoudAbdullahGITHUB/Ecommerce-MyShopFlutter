import 'package:flutter/material.dart';
import 'package:my_shop_flutter_app/providers/cart.dart';
import 'package:provider/provider.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  const CartItem(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    /// this Dismissible to be able to make an action like delete it when pull this widget to left
    return Dismissible(
        key: ValueKey(id),
        background: Container(
          color: Theme.of(context).errorColor,
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 40,
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.only(right: 20),
          margin: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) {
          return showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: Text("Are you sure?"),
                    content: Text(''),
                    actions: [
                      FlatButton(
                        child: Text('No'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      FlatButton(
                        child: Text('Yes'),

                        /// note that i passed true as a parameter on pop(true) function
                        /// that mean this element will be deleted from the design of this screen because from the meaning of
                        /// the name of the function Dismissible() witch dismiss the element from this design but
                        /// actually it did not been deleted from the Your Cart
                        onPressed: () => Navigator.of(context).pop(true),
                      )
                    ],
                  ));
        },
        onDismissed: (direction) {
          Provider.of<Cart>(context, listen: false).removeItem(productId);
          
        },
        child: Card(
          margin: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
          child: Padding(
              padding: EdgeInsets.all(8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Padding(
                    padding: EdgeInsets.all(5),

                    /// this FittedBox because CircleAvatar is so small so FittedBox make CircleAvatar bigger
                    child: FittedBox(
                      child: Text('\$$price'),
                    ),
                  ),
                ),
                title: Text(title),
                subtitle: Text('Total \$${price * quantity}'),
                trailing: Text('$quantity x'),
              )),
        ));
  }
}
