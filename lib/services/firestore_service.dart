import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Tambah transaksi
  Future<void> addTransaction(
    String description,
    int amount,
    DateTime date,
    String categoryId,
    int type,
  ) async {
    try {
      await _db.collection('transactions').add({
        'description': description,
        'amount': amount,
        'transaction_date': date.toIso8601String(),
        'categoryId': categoryId,
        'type': type, // Tambahkan field ini untuk memastikan kategori
        'categoryType': type, // Sinkronisasi dengan HomePage
      });
    } catch (e) {
      print("Error adding transaction: $e");
      rethrow;
    }
  }

  Future<void> updateTransaction(
    String transactionId,
    String description,
    int amount,
    DateTime date,
    String categoryId,
    int type,
  ) async {
    try {
      await _db.collection('transactions').doc(transactionId).update({
        'description': description,
        'amount': amount,
        'transaction_date': date.toIso8601String(),
        'categoryId': categoryId,
        'type': type, // Perbarui tipe kategori
        'categoryType': type, // Sinkronisasi dengan HomePage
      });
    } catch (e) {
      print("Error updating transaction: $e");
      rethrow;
    }
  }

  // Ambil kategori berdasarkan tipe
  Stream<List<Map<String, dynamic>>> getCategories(int type) {
    return _db
        .collection('categories')
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                'name': doc['name'],
              };
            }).toList());
  }

  // Ambil transaksi berdasarkan ID
  Future<Map<String, dynamic>> getTransactionById(String id) async {
    var doc = await _db.collection('transactions').doc(id).get();
    return doc.data()!;
  }
}
