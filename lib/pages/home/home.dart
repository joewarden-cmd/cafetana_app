import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_food_ordering/pages/home/filter_list.dart';
import '../../services/category.dart';
import '../../services/product.dart';
import '../../widgets/carousel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final AllProductService allProductStream = AllProductService();
  final ProductImageService productImageService = ProductImageService();
  final AllCategoryService allCategoryService = AllCategoryService();

  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();

  HomePage({super.key});

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
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              StreamBuilder<List<String>>(
                stream: productImageService.getAllProductImageUrlsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }
                  return ImageCarousel(imageUrls: snapshot.data!);
                },
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<String>>(
                stream: AllCategoryService().getAllCategoryStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No categories available.");
                  }

                  List<String> categories = snapshot.data!;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: OutlinedButton(
                            onPressed: () {
                              String selectedCategory = category;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FilterList(category: selectedCategory),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.lightGreen,
                              side: const BorderSide(
                                  color: Colors.lightGreen, width: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<DocumentSnapshot>>(
                stream: allProductStream.getAllProductStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List productList = snapshot.data!;

                    return GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = productList[index];

                        Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                        String productText = data['productName'];
                        String priceText = data['price'];
                        String imageUrl = data['imageUrl'];

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  productText,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                subtitle: Text(
                                  "₱$priceText",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightGreen,
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    addToCart(context, productText, priceText,
                                        imageUrl);
                                  },
                                  icon: const Icon(Icons.shopping_cart,
                                      color: Colors.lightGreen),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("No data"));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
