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

  DateTime? _startDate;
  DateTime? _endDate;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _startDate =
        DateTime.now().subtract(Duration(days: 7)); // Default 7 hari terakhir
    _endDate = DateTime.now();
    _fetchFinancialData();
  }

  // Fungsi untuk membaca dan menghitung total pendapatan & pengeluaran
  Future<void> _fetchFinancialData() async {
    double income = 0.0;
    double expense = 0.0;

    try {
      QuerySnapshot snapshot =
          await _firestore.collection('transactions').get();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Konversi transaction_date dari String ke DateTime
        DateTime transactionDate = DateTime.parse(data['transaction_date']);

        // Filter transaksi berdasarkan rentang tanggal
        if (transactionDate.isAfter(_startDate!) &&
            transactionDate.isBefore(_endDate!.add(Duration(days: 1)))) {
          if (data['type'] == 1) {
            // Type 1 = Pendapatan
            income += data['amount'].toDouble();
          } else if (data['type'] == 2) {
            // Type 2 = Pengeluaran
            expense += data['amount'].toDouble();
          }
        }
      }

      setState(() {
        _totalIncome = income;
        _totalExpense = expense;
      });
    } catch (e) {
      print("Error fetching financial data: $e");
    }
  }

  // Format mata uang ke format Rupiah
  String formatCurrency(double amount) {
    final format = NumberFormat.simpleCurrency(locale: 'id_ID');
    return format.format(amount);
  }

  // Fungsi untuk memilih tanggal
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate!, end: _endDate!),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null &&
        (picked.start != _startDate || picked.end != _endDate)) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchFinancialData();
    }
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
        iconTheme: const IconThemeData(
          // Set drawer and icon color to white
          color: Colors.white,
        ),
        foregroundColor:
            Colors.white, // Set back button and actions icon color to white
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Pilih Tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih Tanggal:',
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                TextButton(
                  onPressed: () => _selectDateRange(context),
                  child: Text(
                    '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Total pendapatan, pengeluaran, dan saldo
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

            // Daftar transaksi untuk periode
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: _firestore.collection('transactions').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Tidak ada transaksi'));
                  }

                  var transactions = snapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    DateTime transactionDate =
                        DateTime.parse(data['transaction_date']);
                    return transactionDate.isAfter(_startDate!) &&
                        transactionDate
                            .isBefore(_endDate!.add(Duration(days: 1)));
                  }).toList();

                  if (transactions.isEmpty) {
                    return Center(child: Text('Tidak ada transaksi'));
                  }

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      var transaction =
                          transactions[index].data() as Map<String, dynamic>;
                      DateTime transactionDate =
                          DateTime.parse(transaction['transaction_date']);
                      double amount = transaction['amount'].toDouble();
                      String description = transaction['description'];
                      String type = transaction['type'] == 1
                          ? 'Pendapatan'
                          : 'Pengeluaran';

                      return ListTile(
                        title: Text(description),
                        subtitle: Text(
                          '${DateFormat('dd MMM yyyy').format(transactionDate)}',
                        ),
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
