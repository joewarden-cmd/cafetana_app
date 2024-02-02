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
  late final String userId; // Use late to avoid null safety issues

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
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
            .where(userId)
            .orderBy("deleteTimestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List orderList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = orderList[index];
                String productId = document['productId'];
                Timestamp deleteTimestamp = document['deleteTimestamp'];

                DateTime dateTime = deleteTimestamp.toDate(); // Convert Timestamp to DateTime
                String formattedTimestamp = "${dateTime.toLocal()}"; // Format the DateTime as a string

                return ListTile(
                  title: Text("Tracking Number: $productId"),
                  subtitle: Text("Ordered Date: $formattedTimestamp"),
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
}
