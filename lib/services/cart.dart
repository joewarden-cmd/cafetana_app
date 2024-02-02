import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final CollectionReference products =
  FirebaseFirestore.instance.collection("users");

  Stream<QuerySnapshot> getCartStream(String userId) {
    final cartStream = products
        .doc(userId)
        .collection("cart")
        .orderBy("timestamp", descending: true)
        .snapshots();

    return cartStream;
  }

  Stream<QuerySnapshot> getOrderStream(String userId) {
    final orderStream = FirebaseFirestore.instance
        .collection("orders")
        .where("userId", isEqualTo: userId)
        .orderBy("deleteTimestamp", descending: true)
        .snapshots();

    return orderStream;
  }

  Future<void> clearCart(String userId) async {
    // Get references to "cart" and "orders" collections
    final cartReference = products.doc(userId).collection("cart");
    final orderReference = FirebaseFirestore.instance.collection("orders");

    // Get all documents from the "cart" collection
    final QuerySnapshot cartSnapshot = await cartReference.get();

    // Delete each document in the "cart" collection
    for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
      // Store the deleted item in the "orders" collection
      await orderReference.add({
        'userId': userId,
        'productId': doc.id,
        'deleteTimestamp': FieldValue.serverTimestamp(),
      });

      // Delete the item from the "cart" collection
      await cartReference.doc(doc.id).delete();
    }
  }
}
