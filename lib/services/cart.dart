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
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('info')
        .doc('data')
        .get();

    final QuerySnapshot cartSnapshot = await cartReference.get();

    List<Map<String, dynamic>> cartItems = [];
    double total = 0.0;

    for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
      Map<String, dynamic> itemData = doc.data() as Map<String, dynamic>;
      cartItems.add(itemData);

      double price = double.tryParse(itemData['price']) ?? 0.0;
      total += price;

      await cartReference.doc(doc.id).delete();
    }
    String customerName = userData['name'] ?? 'Unknown';

    await orderReference.add({
      'userId': userId,
      'customer': customerName,
      'total': total,
      'itemData': cartItems,
      'transactionTimestamp': FieldValue.serverTimestamp(),
      'status': 'Pending',
    });
  }
}
