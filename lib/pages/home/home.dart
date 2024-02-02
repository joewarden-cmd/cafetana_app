import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/product.dart';
import '../../widgets/carousel.dart';
import 'drink_list.dart';
import 'food_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final AllProductService allProductStream = AllProductService();
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();

  HomePage({super.key});

  void addToCart(String productName, String priceText, String imageUrl) async {
    var userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    int quantity = 1;

    await userDocRef.collection('cart').add({
      'product': productName,
      'price': priceText,
      'quantity': quantity,
      'image': imageUrl,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // const SizedBox(height: 20),
                // TextField(
                //   controller: searchController,
                //   decoration: InputDecoration(
                //     prefixIcon: const Icon(Icons.search),
                //     hintText: 'Search products...',
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     filled: true,
                //     fillColor: Colors.grey[200],
                //   ),
                // ),
                // const SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     GestureDetector(
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(builder: (context) => const MyFoods()),
                //         );
                //       },
                //       child: const Column(
                //         children: [
                //           CircleAvatar(
                //             radius: 30,
                //             backgroundColor: Colors.green,
                //             child: Icon(
                //               Icons.fastfood,
                //               color: Colors.white,
                //             ),
                //           ),
                //           SizedBox(height: 8),
                //           Text(
                //             "FOODS",
                //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                //           ),
                //         ],
                //       ),
                //     ),
                //     GestureDetector(
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(builder: (context) => const MyDrinks()),
                //         );
                //       },
                //       child: const Column(
                //         children: [
                //           CircleAvatar(
                //             radius: 30,
                //             backgroundColor: Colors.green,
                //             child: Icon(
                //               Icons.local_drink,
                //               color: Colors.white,
                //             ),
                //           ),
                //           SizedBox(height: 8),
                //           Text(
                //             "DRINKS",
                //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 20),
                // const Text(
                //   "WHAT'S NEW",
                //   style: TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.green,
                //   ),
                // ),
                const SizedBox(height: 20),
                ImageCarousel(
                  imageUrls: const [
                    'https://raw.githubusercontent.com/curiouslumber/Ecostora/main/images/Categories/apples.jpg',
                    'https://raw.githubusercontent.com/curiouslumber/Ecostora/main/images/Categories/avacados.jpg',
                    'https://raw.githubusercontent.com/curiouslumber/Ecostora/main/images/Categories/spinach.jpg',
                  ],
                ),
                const SizedBox(height: 20),
                // const Text(
                //   "HOT PICKS",
                //   style: TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.green,
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Align buttons in the center
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Action for button press (e.g., navigate to another screen)
                        print("Hot Picks button pressed!");
                      },
                      child: const Text(
                        "See Hot Picks",
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Set button color
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add space between the buttons
                    ElevatedButton(
                      onPressed: () {
                        // Action for button press (e.g., navigate to another screen)
                        print("Hot Picks button pressed!");
                      },
                      child: const Text(
                        "See Hot Picks",
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Set button color
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: allProductStream.getAllProductStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List productList = snapshot.data!.docs;

                      return GridView.builder(
                        shrinkWrap: true,
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
                                  title: Text(productText),
                                  subtitle: Text("\$$priceText"),
                                  trailing: IconButton(
                                    onPressed: () {
                                      addToCart(productText, priceText, imageUrl);
                                    },
                                    icon: const Icon(Icons.shopping_cart),
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
      ),
    );
  }
}
