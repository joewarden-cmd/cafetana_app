import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({Key? key}) : super(key: key);

  @override
  _MyOrderPageState createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  void _showProductDetails(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Product Details"),
          content: FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection("products").doc(productId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text("Error fetching product details");
              } else if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text("Product not found");
              } else {
                var product = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Name: ${product['name']}"),
                    Text("Price: \$${product['price']}"),
                    Text("Description: ${product['description']}"),
                  ],
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("orders")
        // .where("userId", isEqualTo: userId) // Uncomment if user-specific data is needed
            .orderBy("deleteTimestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List orderList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = orderList[index];
                // String productId = document['productId'];
                String productId = "order123";
                Timestamp deleteTimestamp = document['deleteTimestamp'];

                DateTime dateTime = deleteTimestamp.toDate();
                String formattedTimestamp = "${dateTime.toLocal()}";

                // String orderStatus = document['status'] ?? 'Pending';
                String orderStatus = 'Pending';
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tracking Number: $productId",
                              style:
                              const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(orderStatus),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                orderStatus,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("Ordered Date: $formattedTimestamp"),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              _showProductDetails(context, productId),
                          child: const Text("View Product Details"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No ordered items"));
          }
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Shipped':
        return Colors.green;
      case 'Processing':
        return Colors.blue;
      case 'Delivered':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
