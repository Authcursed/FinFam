import 'package:cloud_firestore/cloud_firestore.dart';

// Pastikan ini adalah file FirestoreService Anda
class FirestoreService {
  final CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');
  final CollectionReference transactions =
      FirebaseFirestore.instance.collection('transactions');

  // CRUD Category (Kategori)

  Future<void> addCategory(String name, int type) async {
    await categories.add({
      'name': name,
      'type': type,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'deletedAt': null,
    });
  }

  Future<void> updateCategory(String id, String newName) async {
    await categories.doc(id).update({
      'name': newName,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteCategory(String id) async {
    await categories.doc(id).update({
      'deletedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> getCategories(int type) {
    return categories
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    });
  }

  // CRUD Transaction (Transaksi)

  Future<void> addTransaction(
      String description, int amount, DateTime date, String categoryId) async {
    await transactions.add({
      'description': description,
      'amount': amount,
      'transaction_date': date.toIso8601String(),
      'categoryId': categoryId,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateTransaction(String id, String newDescription,
      int newAmount, DateTime newDate, String newCategoryId) async {
    await transactions.doc(id).update({
      'description': newDescription,
      'amount': newAmount,
      'transaction_date': newDate.toIso8601String(),
      'categoryId': newCategoryId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteTransaction(String id) async {
    await transactions.doc(id).delete();
  }

  Stream<List<Map<String, dynamic>>> getTransactionsByDate(DateTime date) {
    return transactions
        .where('transaction_date', isEqualTo: date.toIso8601String())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    });
  }

  Future<Map<String, dynamic>> getTransactionById(String id) async {
    final doc = await transactions.doc(id).get();
    return {
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    };
  }
}
