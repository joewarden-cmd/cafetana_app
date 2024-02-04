import 'package:cloud_firestore/cloud_firestore.dart';

class AllProductService {
  final CollectionReference allProducts =
  FirebaseFirestore.instance.collection("product2");

  Stream<List<DocumentSnapshot>> getAllProductStream() async* {
    QuerySnapshot snapshot = await allProducts.get();
    List<DocumentSnapshot> shuffledProducts = List.from(snapshot.docs)..shuffle();

    yield shuffledProducts.take(10).toList();
  }
}



class ProductImageService {
  final CollectionReference allProductsImage =
  FirebaseFirestore.instance.collection("product2");

  Stream<List<String>> getAllProductImageUrlsStream() {
    return allProductsImage
        .orderBy("createdAt", descending: true)
        .limit(10)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => doc['imageUrl'] as String)
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