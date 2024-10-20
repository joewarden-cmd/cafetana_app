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
        .orderBy("transactionTimestamp", descending: true)
        .snapshots();

    return orderStream;
  }

  Future<void> clearCart(String userId) async {
    final cartReference = products.doc(userId).collection("cart");
    final orderReference = FirebaseFirestore.instance.collection("orders");

    final QuerySnapshot cartSnapshot = await cartReference.get();

    List<Map<String, dynamic>> cartItems = [];

    for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
      Map<String, dynamic> itemData = doc.data() as Map<String, dynamic>;
      cartItems.add(itemData);
      await cartReference.doc(doc.id).delete();
    }

    await orderReference.add({
      'userId': userId,
      'itemData': cartItems,
      'transactionTimestamp': FieldValue.serverTimestamp(),
      'status': 'Pending',
    });

  }
}
