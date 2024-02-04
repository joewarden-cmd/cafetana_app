import 'package:cloud_firestore/cloud_firestore.dart';

class AllCategoryService {
  final CollectionReference allCategory =
  FirebaseFirestore.instance.collection("category");

  Stream<List<String>> getAllCategoryStream() {
    return allCategory.snapshots().map((snapshot) {
      List<String> categories = [];
      for (var doc in snapshot.docs) {
        String categoryName = doc['categoryName'];
        categories.add(categoryName);
            }
      return categories;
    });
  }
}
