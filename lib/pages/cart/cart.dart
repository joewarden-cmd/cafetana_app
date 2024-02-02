import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/cart.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  final CartService cartService = CartService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> removeFromCart(String productId) async {
    // Implement the logic to remove the product from the cart
    // You might use cartService.removeProduct(productId);
  }

  Future<Map<String, dynamic>> calculateTotal() async {
    double total = 0.0;
    Map<String, int> productCounts = {};  // To store product count
    QuerySnapshot snapshot = await cartService.getCartStream(userId).first;
    List productList = snapshot.docs;

    for (var document in productList) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      String productName = data['product'];
      double price = double.tryParse(data['price'].toString()) ?? 0.0;

      total += price;

      // Increment the count for the product
      if (productCounts.containsKey(productName)) {
        productCounts[productName] = productCounts[productName]! + 1;
      } else {
        productCounts[productName] = 1;
      }
    }

    return {
      'total': total,
      'productCounts': productCounts,
    };
  }
  void openCheckoutBox() async {
    // Get total and product counts
    Map<String, dynamic> result = await calculateTotal();
    double totalPrice = result['total'];
    Map<String, int> productCounts = result['productCounts'];

    // Build the product list string
    String productListString = "";
    productCounts.forEach((product, count) {
      productListString += "$product x$count\n";
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Products in your cart:\n$productListString"),
            const SizedBox(height: 10),
            Text("Total Price: \$${totalPrice.toStringAsFixed(2)}"),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Call a method to delete everything from the cart
                cartService.clearCart(userId);

                // Close the dialog after confirming the order
                Navigator.of(context).pop();
              },
              child: const Text("Confirm Order"),
            ),
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: cartService.getCartStream(userId),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  List productList = snapshot.data!.docs;
            
                  return ListView.builder(
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = productList[index];
                      String docID = document.id;
            
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      String productText = data['product'];
                      String priceText = data['price'];
                      String productImg = data['image'];
            
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(productImg),
                        ),
                        title: Text(productText),
                        subtitle: Text("\$$priceText"),
                        trailing: IconButton(
                          onPressed: () {
                            removeFromCart(docID);
                          },
                          icon: const Icon(Icons.remove_shopping_cart),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("No data"));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  openCheckoutBox();
                },
                child: const Text("Checkout"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
