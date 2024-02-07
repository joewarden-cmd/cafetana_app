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

  Future<void> removeFromCart(
      context, String productName, String productId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$productName has been removed.",
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80.0),
      ),
    );
    final cartReference = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart');
    await cartReference.doc(productId).delete();
  }

  Future<void> incrementQuantity(String productId, int currentQuantity) async {
    final cartReference = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId);

    await cartReference.update({
      'quantity': currentQuantity + 1,
    });
  }

  Future<Map<String, dynamic>> calculateTotal() async {
    double total = 0.0;
    Map<String, int> productCounts = {};
    QuerySnapshot snapshot = await cartService.getCartStream(userId).first;
    List productList = snapshot.docs;

    for (var document in productList) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      String productName = data['product'];
      double price = double.tryParse(data['price'].toString()) ?? 0.0;

      total += price * data['quantity'];

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
    Map<String, dynamic> result = await calculateTotal();
    double totalPrice = result['total'];
    Map<String, int> productCounts = result['productCounts'];

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
            Text("Total Price: ₱${totalPrice.toStringAsFixed(2)}"),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                cartService.clearCart(userId);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Order has been placed..",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(bottom: 80.0),
                  ),
                );

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
      appBar: AppBar(title: const Text("Cart")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: cartService.getCartStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Your cart is empty"));
                } else {
                  List productList = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = productList[index];
                      String docID = document.id;

                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String productText = data['product'];
                      String priceText = data['price'];
                      String productImg = data['image'];
                      int quantity = data['quantity'];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(productImg),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productText,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("₱$priceText"),
                                    Text("Quantity: $quantity"),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      incrementQuantity(docID, quantity);
                                    },
                                    icon: const Icon(Icons.add),
                                    color: Colors.green,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      removeFromCart(
                                          context, productText, docID);
                                    },
                                    icon:
                                        const Icon(Icons.remove_shopping_cart),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
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
