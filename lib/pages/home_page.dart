import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:FinFam/services/firestore_service.dart';
import 'package:FinFam/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;

  HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double totalPendapatan = 0.0;
  double totalPengeluaran = 0.0;
  late DateTime selectedDate;
  FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    _updateTotals();
  }

  // Format Rupiah
  String formatRupiah(double amount) {
    var formatCurrency = NumberFormat.simpleCurrency(locale: 'id_ID');
    return formatCurrency.format(amount);
  }

  // Format Waktu
  String formatWaktu(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Mengupdate total pendapatan dan pengeluaran
  void _updateTotals() async {
    double pendapatan = 0.0;
    double pengeluaran = 0.0;

    DateTime startOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .get(); // Ambil semua transaksi tanpa filter waktu terlebih dahulu

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      // Konversi transaction_date dari String ke DateTime
      DateTime transactionDate = DateTime.parse(data['transaction_date']);

      // Filter transaksi berdasarkan waktu
      if (transactionDate.isAfter(startOfDay) &&
          transactionDate.isBefore(endOfDay)) {
        if (data['type'] == 1) {
          // Type 1 = Pendapatan
          pendapatan += data['amount'].toDouble();
        } else if (data['type'] == 2) {
          // Type 2 = Pengeluaran
          pengeluaran += data['amount'].toDouble();
        }
      }
    }

    setState(() {
      totalPendapatan = pendapatan;
      totalPengeluaran = pengeluaran;
    });
  }

  // Menavigasi ke halaman TransactionPage
  void _navigateToTransactionPage({String? transactionId}) async {
    bool isUpdated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionPage(
              transactionId: transactionId,
              resetCategoryOnSwitch: true,
            ),
          ),
        ) ??
        false;

    if (isUpdated) {
      _updateTotals();
    }
  }

  // Menghapus transaksi
  void _deleteTransaction(String transactionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Transaksi berhasil dihapus"),
        backgroundColor: Colors.green,
      ));
      _updateTotals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Gagal menghapus transaksi: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Stream untuk transaksi berdasarkan tanggal
  Stream<QuerySnapshot> getTransactionsStream() {
    DateTime startOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('transaction_date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('transaction_date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('transaction_date', descending: true)
        .snapshots();
  }

  // Mengubah tanggal sebelumnya atau setelahnya
  void _changeDate(int offset) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: offset));
    });
    _updateTotals();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children: [
            // Bar Tanggal dengan tombol navigasi
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: () => _changeDate(-1), // Tanggal sebelumnya
                    color: Colors.blue,
                  ),
                  // Menambahkan GestureDetector untuk klik tanggal
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate:
                            DateTime(2000), // Tanggal awal yang diperbolehkan
                        lastDate:
                            DateTime(2100), // Tanggal akhir yang diperbolehkan
                      );

                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                        _updateTotals(); // Perbarui total pendapatan dan pengeluaran
                      }
                    },
                    child: Text(
                      DateFormat('dd MMMM yyyy').format(selectedDate),
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: () => _changeDate(1), // Tanggal setelahnya
                    color: Colors.blue,
                  ),
                ],
              ),
            ),

            // Menampilkan total pendapatan dan pengeluaran
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Pendapatan
                        Row(
                          children: [
                            Icon(Icons.download, color: Colors.blueAccent[400]),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pendapatan',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12, color: Colors.white)),
                                SizedBox(height: 5),
                                Text(formatRupiah(totalPendapatan),
                                    style: GoogleFonts.montserrat(
                                        fontSize: 14, color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                        // Pengeluaran
                        Row(
                          children: [
                            Icon(Icons.upload, color: Colors.redAccent[400]),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pengeluaran',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12, color: Colors.white)),
                                SizedBox(height: 5),
                                Text(formatRupiah(totalPengeluaran),
                                    style: GoogleFonts.montserrat(
                                        fontSize: 14, color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Daftar Transaksi Berdasarkan Tanggal
            Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('transactions')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    var transactions = snapshot.data!.docs;

                    // Filter transaksi berdasarkan tanggal
                    DateTime startOfDay = DateTime(selectedDate.year,
                        selectedDate.month, selectedDate.day);
                    DateTime endOfDay = startOfDay.add(Duration(days: 1));

                    var filteredTransactions = transactions.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      DateTime transactionDate =
                          DateTime.parse(data['transaction_date']);
                      return transactionDate.isAfter(startOfDay) &&
                          transactionDate.isBefore(endOfDay);
                    }).toList();

                    if (filteredTransactions.isEmpty) {
                      return Center(child: Text("Tidak ada data"));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        var transaction = filteredTransactions[index].data()
                            as Map<String, dynamic>;
                        DateTime transactionDate =
                            DateTime.parse(transaction['transaction_date']);

                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: Icon(
                              transaction['type'] == 1
                                  ? Icons.download
                                  : Icons.upload,
                              color: transaction['type'] == 1
                                  ? Colors.blueAccent
                                  : Colors.redAccent,
                            ),
                            title: Text(
                              transaction['description'],
                              style: GoogleFonts.montserrat(fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatRupiah(
                                      transaction['amount'].toDouble()),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Waktu: ${formatWaktu(transactionDate)}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _navigateToTransactionPage(
                                      transactionId:
                                          filteredTransactions[index].id);
                                } else if (value == 'delete') {
                                  _deleteTransaction(
                                      filteredTransactions[index].id);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text("Edit"),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text("Hapus"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("Tidak ada data"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
