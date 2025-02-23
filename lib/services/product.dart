import 'package:cloud_firestore/cloud_firestore.dart';

class AllProductService {
  final CollectionReference allProducts =
      FirebaseFirestore.instance.collection("product2");

  Stream<List<DocumentSnapshot>> getAllProductStream() {
    return allProducts
        .where('status', isEqualTo: "Published")
        .snapshots()
        .map((snapshot) {
      List<DocumentSnapshot> shuffledProducts = List.from(snapshot.docs)
        ..shuffle();
      return shuffledProducts.toList();
    });
  }
}

class ProductImageService {
  final CollectionReference allProductsImage =
      FirebaseFirestore.instance.collection("product2");

  Stream<List<String>> getAllProductImageUrlsStream() {
    return allProductsImage
        .where('status', isEqualTo: "Published")
        .orderBy("createdAt", descending: true)
        .limit(10)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return data.containsKey('imageUrl')
                ? data['imageUrl'] as String
                : '';
          })
          .where((url) => url.isNotEmpty)
          .toList();
    });
  }
}

class FilterService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Add category parameter to filter the products
  Stream<QuerySnapshot> getFoodStream({required String category}) {
    return firestore
        .collection('product2') // Assuming your collection is named 'products'
        .where('category', isEqualTo: category) // Filter by category
        .where('status', isEqualTo: "Published")
        .snapshots();
  }
}

class DrinkService {
  final CollectionReference drinks =
      FirebaseFirestore.instance.collection("product2");

  // Future<void> addProduct(String food, String price, String image) {
  //   return drinks.add({
  //     'drink': food,
  //     'price' : price,
  //     'image' : image,
  //     'timestamp': Timestamp.now(),
  //   });
  // }

  Stream<QuerySnapshot> getDrinkStream() {
    final drinkStream = drinks
        .where("category", isEqualTo: "Drinks")
        // .orderBy("timestamp", descending: true)
        .snapshots();

    return drinkStream;
  }
}
