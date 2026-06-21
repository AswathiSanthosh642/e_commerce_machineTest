import 'package:e_commerce_product/controllers/cart_controller.dart';
import 'package:e_commerce_product/controllers/product_controller.dart';
import 'package:e_commerce_product/controllers/theme_controller.dart';
import 'package:e_commerce_product/views/cart_page.dart';
import 'package:e_commerce_product/views/login_page.dart';
import 'package:e_commerce_product/views/product_detailedPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themecontroller = Provider.of<ThemeController>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("E-Commerce App"),
        centerTitle: true,
        actions: [
          Consumer<CartController>(
            builder: (context, cart, child) {
              return Stack(
                children: [

                  Row(
                    children: [
                      Switch(
                        value: themecontroller.isDarkMode,
                        onChanged: (value) {
                          themecontroller.toggleTheme();
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
                        },
                        icon: const Icon(Icons.shopping_cart),
                      ),
                    ],
                  ),
                  if (cart.cartCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${cart.cartCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Consumer<CartController>(
              builder: (context, cart, child) {
                return UserAccountsDrawerHeader(
                  accountName: Text(cart.username ?? "Me"),
                  accountEmail: null,
                  currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await Provider.of<CartController>(context, listen: false).logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<ProductController>(
        builder: (BuildContext context, ProductController value, Widget? child) {
          if (value.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (value.productsList == null || value.productsList!.isEmpty) {
            return const Center(child: Text("No Data"));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: value.productsList!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final product = value.productsList![index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ProductDetailedpage(product_id: product.id),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network("${product.thumbnail}"),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${product.title}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Rs: ${product.price}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.orange),
                                Text("${product.rating}"),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
