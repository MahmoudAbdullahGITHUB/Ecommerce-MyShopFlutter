import 'package:flutter/material.dart';
import 'package:my_shop_flutter_app/providers/cart.dart';
import 'package:my_shop_flutter_app/providers/products.dart';
import 'package:my_shop_flutter_app/screens/cart_screen.dart';
import 'package:my_shop_flutter_app/widgets/app_drawer.dart';
import 'package:my_shop_flutter_app/widgets/badge.dart';

import 'package:my_shop_flutter_app/widgets/products_grid.dart';
import 'package:provider/provider.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _isLoading = false;
  var _showOnlyFavorites = false;

  @override
  initState() {
    super.initState();
    _isLoading = true;

    /// note that we use context inside initState() function but with the provider
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then(
          (_) => setState(
            /// i used setState here because _isLoading is parameter in this class not on the provider;
            () => _isLoading = false,
          ),
        )
        .catchError((error) => setState(
              () => _isLoading = false,
            ));
  }

  @override
  Widget build(BuildContext context) {
    // final productsContainer = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
                print(selectedValue);
              });
            },
          ),

          /// why i made consumer here ? only i used here to get Cart.itemCount.
          Consumer<Cart>(
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () => Navigator.of(context).pushNamed(CartScreen.routName),
            ),

            /// note that child above will be passed to ch variable on builder
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
      drawer: AppDrawer(),
    );
  }
}
