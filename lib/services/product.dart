import 'package:cloud_firestore/cloud_firestore.dart';

class AllProductService {
  final CollectionReference allProducts =
  FirebaseFirestore.instance.collection("product2");

  Stream<QuerySnapshot> getAllProductStream() {
    final allProductStream = allProducts
        .orderBy("createdAt", descending: true)
        .limit(10)
        .snapshots();

    return allProductStream;
  }
}

class FoodService {
  final CollectionReference foods =
      FirebaseFirestore.instance.collection("product2");

  // Future<void> addProduct(String food, String price, String image) {
  //   return foods.add({
  //     'food': food,
  //     'price' : price,
  //     'image' : image,
  //     'timestamp': Timestamp.now(),
  //   });
  // }

  Stream<QuerySnapshot> getFoodStream() {
    final foodStream = foods
        .where("category", isEqualTo: "Foods")
        // .orderBy("createdAt", descending: true)
        .snapshots();

    return foodStream;
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