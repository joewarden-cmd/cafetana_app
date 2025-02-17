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

  Future<void> decrementQuantity(String productId, int currentQuantity) async {
    if (currentQuantity > 1) {
      final cartReference = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId);

      await cartReference.update({
        'quantity': currentQuantity - 1,
      });
    }
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
      double price = double.tryParse(data['price'].toString()) ?? 0.0;
      String productName = data['product'];
      int quantity = data['quantity'] is num
          ? (data['quantity'] as num).toInt()
          : data['quantity'];

      total += price * quantity;

      if (productCounts.containsKey(productName)) {
        productCounts[productName] = productCounts[productName]! + quantity;
      } else {
        productCounts[productName] = quantity;
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
    String? selectedPaymentMethod = 'Credit Card';

    String productListString = "";
    productCounts.forEach((product, count) {
      productListString += "$product x$count\n";
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Products in your cart."),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(productListString),
                  DropdownButton<String>(
                    value: selectedPaymentMethod,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPaymentMethod = newValue;
                      });
                    },
                    hint: Text(
                      'Select Payment Method',
                      style: TextStyle(color: Colors.grey),
                    ),
                    items: <String>[
                      'Credit Card',
                      'GCash',
                      'Maya',
                      'PayPal',
                      'Cash on Delivery'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 12.0),
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    icon: Icon(
                      Icons.payment,
                      color: Colors.lightGreen,
                    ),
                    iconSize: 24,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    underline: Container(
                      height: 2,
                      color: Colors.lightGreen,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Total Price: ₱${totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.lightGreen,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    cartService.clearCart(userId, selectedPaymentMethod);

                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Order has been placed using $selectedPaymentMethod.",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(bottom: 80.0),
                      ),
                    );
                  },
                  child: const Text("Confirm Order"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightGreen, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            'Cart',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
      ),
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
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 60,
                          color: Colors.lightGreen,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "You cart is empty",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
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
                                    Text(productText),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₱$priceText",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.lightGreen,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 25.0,
                                    height: 25.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.lightGreen,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        decrementQuantity(docID, quantity);
                                      },
                                      icon: const Icon(Icons.remove),
                                      color: Colors.lightGreen,
                                      iconSize: 20.0,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text("$quantity"),
                                  ),
                                  Container(
                                    width: 25.0,
                                    height: 25.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.lightGreen,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        incrementQuantity(docID, quantity);
                                      },
                                      icon: const Icon(Icons.add),
                                      color: Colors.lightGreen,
                                      iconSize: 20.0,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      removeFromCart(
                                          context, productText, docID);
                                    },
                                    icon: const Icon(Icons.delete),
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.lightGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
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
