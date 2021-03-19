import 'package:flutter/material.dart';
import 'package:my_shop_flutter_app/providers/auth.dart';
import 'package:my_shop_flutter_app/providers/cart.dart';
import 'package:my_shop_flutter_app/providers/orders.dart';
import 'package:my_shop_flutter_app/providers/product.dart';
import 'package:my_shop_flutter_app/providers/products.dart';
import 'package:my_shop_flutter_app/screens/auth_screen.dart';
import 'package:my_shop_flutter_app/screens/cart_screen.dart';
import 'package:my_shop_flutter_app/screens/edit_product_screen.dart';
import 'package:my_shop_flutter_app/screens/order_screen.dart';
import 'package:my_shop_flutter_app/screens/product_Overview_screen.dart';
import 'package:my_shop_flutter_app/screens/product_detail_screen.dart';
import 'package:my_shop_flutter_app/screens/splash_screen.dart';
import 'package:my_shop_flutter_app/screens/user_products_screen.dart';
import 'package:my_shop_flutter_app/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import './providers/products.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),

        /// ProxyProvider because Products provider depend on some parameters of Auth() provider
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(),
          update: (ctx, authValue, previousProducts) => previousProducts
            ..getData(
              authValue.token,
              authValue.userId,
              previousProducts.items == null ? null : previousProducts.items,
            ),
        ),
        ChangeNotifierProvider.value(value: Cart()),

        /// ProxyProvider because Orders provider depend on some parameters of Auth() provider
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(),
          update: (ctx, authValue, previousOrders) => previousOrders

            /// i do not know why ..getData() why not .getData()
            ..getData(
              authValue.token,
              authValue.userId,
              previousOrders.orders == null ? null : previousOrders.orders,
            ),
        ),
        //ChangeNotifierProvider.value(value: Product())
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
              primarySwatch: Colors.blue, accentColor: Colors.deepOrange, fontFamily: 'Lato'),
          home: auth.isAuth
              ? ProductOverviewScreen()

              /// what is the use of FutureBuilder
              /// this FutureBuilder widget only used only with any coming data in future
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, AsyncSnapshot authSnapshot) =>
                      authSnapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routName: (_) => ProductDetailScreen(),
            OrderScreen.routName: (_) => OrderScreen(),
            UserProductsScreen.routName: (_) => UserProductsScreen(),
            CartScreen.routName: (_) => CartScreen(),
            EditProductScreen.routName: (_) => EditProductScreen(),

            // ProductDetailScreen.routName: (_) => ProductDetailScreen(),
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
      ),
      body: Center(
        child: Text('Let\'s build a shop!'),
      ),
    );
  }
}
