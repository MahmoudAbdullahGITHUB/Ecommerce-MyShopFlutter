import 'package:flutter/material.dart';
import 'package:my_shop_flutter_app/providers/products.dart';
import 'package:my_shop_flutter_app/providers/product.dart';
import 'package:my_shop_flutter_app/widgets/product_item.dart';
import 'package:provider/provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;


  const ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavs ? productsData.favoritesItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,

      /// i do not understand why ChangeNotifierProvider ? i think that i make provider for single product because products[i] = product
      /// and i did not make listen for product provider on the main screen
      itemBuilder: (ctx, i) =>
          ChangeNotifierProvider.value(
            value: products[i],
            child: ProductItem(
              // products[i].id,
              // products[i].title,
              // products[i].imageUrl,
            ),
          ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
