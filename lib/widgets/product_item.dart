import 'package:flutter/material.dart';
import 'package:my_shop_flutter_app/providers/auth.dart';
import 'package:my_shop_flutter_app/providers/cart.dart';
import 'package:my_shop_flutter_app/providers/product.dart';
import 'package:my_shop_flutter_app/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;
  //
  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    /// why ClipRRect ?? it is used to make corner for image itself
    /// but the card make corner for the card itself not the image
    /// so if the image bigger than the card it will not been have BorderRadius so i used ClipRRect
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),

      /// note that this widget is GridTile witch has GridTileBar as a footer and it is not gridView
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routName,
              arguments: product.id,
            );
          },

          /// this hero only for animation
          child: Hero(

              /// this tag only used for animation.
              tag: product.id,

              /// this FadeInImage just to display default image until image downloaded form the network
              child: FadeInImage(
                placeholder: AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              )),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              /// i can't understand how the icon changed without setState
              /// i don't speak about isFavorite variable
              icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border),
              color: Theme.of(context).accentColor,
              onPressed: () {
                product.toggleFavoriteStatus(authData.token, authData.userId);
              },
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);

              /// hide the current Toast because may be i add many items to the cart at the same time so for hiding the previous toast
              /// and display only the last toast of the last item added to cart
              Scaffold.of(context).hideCurrentSnackBar();

              /// like Toast in android
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text("Added to cart!"),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                      label: 'UNDO!',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      }),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
