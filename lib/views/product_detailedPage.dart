import 'package:e_commerce_product/controllers/cart_controller.dart';
import 'package:e_commerce_product/controllers/product_controller.dart';
import 'package:e_commerce_product/views/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailedpage extends StatelessWidget {
  final dynamic product_id;

  const ProductDetailedpage({super.key, required this.product_id});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductController, CartController>(
      builder: (BuildContext context, ProductController productValue, CartController cartValue, Widget? child) {
        final product = productValue.productsList?.firstWhere(
          (element) => element.id == product_id,
        );

        if (product == null) {
          return const Scaffold(body: Center(child: Text("Product not found")));
        }

        final cartItem = cartValue.cartItems.firstWhere(
          (item) => item['productId'] == product.id,
          orElse: () => {},
        );

        final int qty = cartItem['quantity'] ?? 0;

        return Scaffold(
          appBar: AppBar(
            actions: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                  if (cartValue.cartCount > 0)
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
                          '${cartValue.cartCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: product.thumbnail != null
                          ? Image.network(product.thumbnail!)
                          : const Placeholder(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "${product.title}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Category: ${product.category}",
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Rs. ${product.price}",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.orange),
                        Text(
                          " ${product.rating}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: qty > 0 ? () => cartValue.decrementQuantityCart(product_id) : null,
                          icon: Icon(Icons.remove_circle_outline, size: 30, color: qty > 0 ? Colors.red : Colors.grey),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Qty : $qty',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (qty > 0) {
                              cartValue.incrementQuantityCart(product_id);
                            } else {
                              cartValue.addToCart(product);
                            }
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 30, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (qty == 0)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          await cartValue.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Added to cart!")),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("Add to Cart", style: TextStyle(fontSize: 18)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
