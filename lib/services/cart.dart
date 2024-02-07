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
    final cartReference = FirebaseFirestore.instance.collection('users').doc(userId).collection("cart");
    final orderReference = FirebaseFirestore.instance.collection("orders");

    final QuerySnapshot cartSnapshot = await cartReference.get();

    DocumentReference orderDocRef = await orderReference.add({
      'userId': userId,
      'deleteTimestamp': FieldValue.serverTimestamp(),
      'status': 'Pending',
    });

    for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
      Map<String, dynamic> cartData = doc.data() as Map<String, dynamic>;

      await orderDocRef.collection('items').add({
        'productId': doc.id,
        'productData': cartData,
        'deleteTimestamp': FieldValue.serverTimestamp(),
      });

    }
    await cartReference.get().then((cartSnapshot) async {
      for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }
    });
  }

}
