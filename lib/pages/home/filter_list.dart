import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_food_ordering/services/product.dart';

class FilterList extends StatefulWidget {
  final String category;

  const FilterList({super.key, required this.category});

  @override
  State<FilterList> createState() => _MyFilterState();
}

class _MyFilterState extends State<FilterList> {
  final FilterService foodService = FilterService();
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String get category => widget.category;

  void addToCart(BuildContext context, String productName, String priceText,
      String imageUrl) async {
    var userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      var cartSnapshot = await userDocRef
          .collection('cart')
          .where('product', isEqualTo: productName)
          .get();

      if (cartSnapshot.docs.isEmpty) {
        await userDocRef.collection('cart').add({
          'product': productName,
          'price': priceText,
          'quantity': 1,
          'image': imageUrl,
          'timestamp': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$productName has been added to your cart!",
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 80.0),
          ),
        );
      } else {
        var cartItem = cartSnapshot.docs.first;
        int currentQuantity = cartItem['quantity'];
        await cartItem.reference.update({
          'quantity': currentQuantity + 1,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Quantity of $productName has been increased!",
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 80.0),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to add $productName to cart. Please try again.",
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: StreamBuilder<QuerySnapshot>(
        stream: foodService.getFoodStream(category: category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products found"));
          }

          List productList = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = productList[index];
              String docID = document.id;

              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String productText = data['productName'];
              String priceText = data['price'];
              String imageUrl = data['imageUrl'];

              return Card(
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        productText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      subtitle: Text("₱$priceText"),
                      trailing: IconButton(
                        onPressed: () {
                          addToCart(context, productText, priceText, imageUrl);
                        },
                        icon: const Icon(Icons.shopping_cart),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
