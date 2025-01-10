import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FinancialReportPage extends StatefulWidget {
  const FinancialReportPage({Key? key}) : super(key: key);

  @override
  _FinancialReportPageState createState() => _FinancialReportPageState();
}

class _FinancialReportPageState extends State<FinancialReportPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedPeriod = 'weekly'; // Default ke Weekly
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

  // Fungsi untuk mengambil data keuangan berdasarkan periode yang dipilih
  Future<void> _fetchFinancialData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    // Menentukan periode berdasarkan pilihan pengguna
    if (_selectedPeriod == 'weekly') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      endDate = startDate.add(Duration(days: 7));
    } else if (_selectedPeriod == 'monthly') {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0); // Hari terakhir bulan ini
    } else {
      // 'yearly'
      startDate = DateTime(now.year, 1, 1);
      endDate = DateTime(now.year + 1, 1, 1); // 1 Januari tahun depan
    }

    // Mengambil transaksi berdasarkan periode waktu yang ditentukan
    QuerySnapshot transactionsSnapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: currentUser.uid)
        .where('transaction_date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('transaction_date', isLessThan: Timestamp.fromDate(endDate))
        .get();

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    // Menghitung total pendapatan dan pengeluaran
    for (var doc in transactionsSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double amount = data['amount'].toDouble();
      int type = data['type']; // 1 = Pendapatan, 2 = Pengeluaran

      if (type == 1) {
        totalIncome += amount;
      } else if (type == 2) {
        totalExpense += amount;
      }
    }

    setState(() {
      _totalIncome = totalIncome;
      _totalExpense = totalExpense;
    });
  }

  // Menampilkan format uang dalam format Rupiah
  String formatCurrency(double amount) {
    final format = NumberFormat.simpleCurrency(locale: 'id_ID');
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Laporan Keuangan",
          style: GoogleFonts.montserrat(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          // Set drawer and icon color to white
          color: Colors.white,
        ),
        foregroundColor:
            Colors.white, // Set back button and actions icon color to white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Pilihan Skala Periode Laporan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Periode:',
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  items: [
                    DropdownMenuItem(
                      value: 'weekly',
                      child: Text('Mingguan'),
                    ),
                    DropdownMenuItem(
                      value: 'monthly',
                      child: Text('Bulanan'),
                    ),
                    DropdownMenuItem(
                      value: 'yearly',
                      child: Text('Tahunan'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                    });
                    _fetchFinancialData();
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // Menampilkan Total Pendapatan dan Pengeluaran
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              color: Colors.blueGrey[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Total Pendapatan:',
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                        Text(
                          formatCurrency(_totalIncome),
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Total Pengeluaran:',
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                        Text(
                          formatCurrency(_totalExpense),
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Saldo:',
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                        Text(
                          formatCurrency(_totalIncome - _totalExpense),
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Menampilkan Detail Laporan (Opsional)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('transactions')
                    .where('userId', isEqualTo: _auth.currentUser?.uid)
                    .where('transaction_date',
                        isGreaterThanOrEqualTo: Timestamp.fromDate(
                            DateTime.now().subtract(Duration(
                                days: 30)))) // Misalnya untuk 30 hari terakhir
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Tidak ada transaksi'));
                  }

                  var transactions = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      var transaction =
                          transactions[index].data() as Map<String, dynamic>;
                      DateTime transactionDate =
                          (transaction['transaction_date'] as Timestamp)
                              .toDate();
                      double amount = transaction['amount'].toDouble();
                      String description = transaction['description'];
                      String type = transaction['type'] == 1
                          ? 'Pendapatan'
                          : 'Pengeluaran';

                      return ListTile(
                        title: Text(description),
                        subtitle: Text(
                            '${DateFormat('dd MMM yyyy').format(transactionDate)}'),
                        trailing: Text(
                          formatCurrency(amount),
                          style: TextStyle(
                            color: transaction['type'] == 1
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
