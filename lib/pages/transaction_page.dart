import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FinFam/services/firestore_service.dart';

class TransactionPage extends StatefulWidget {
  final String? transactionId;
  final bool resetCategoryOnSwitch;

  const TransactionPage({
    Key? key,
    this.transactionId,
    this.resetCategoryOnSwitch = false,
  }) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  bool isExpense = true;
  late int type;
  FirestoreService firestoreService = FirestoreService();
  String? selectedCategoryId;
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController categoryNameController = TextEditingController();

  final CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');

  @override
  void initState() {
    super.initState();
    type = 2; // Default pengeluaran
    if (widget.transactionId != null) {
      loadTransaction(widget.transactionId!);
    }
  }

  Future<void> loadTransaction(String id) async {
    var transaction = await firestoreService.getTransactionById(id);
    amountController.text = transaction['amount'].toString();
    descriptionController.text = transaction['description'];
    dateController.text = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(transaction['transaction_date']));
    selectedCategoryId = transaction['categoryId'];
    timeController.text = DateFormat('HH:mm')
        .format(DateTime.parse(transaction['transaction_date']));
  }

  Future<void> saveTransaction() async {
    if (amountController.text.isEmpty ||
        selectedCategoryId == null ||
        timeController.text.isEmpty ||
        dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Jumlah, kategori, waktu, dan tanggal harus diisi'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    double amount = double.tryParse(amountController.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Jumlah harus berupa angka yang valid'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      DateTime date = DateTime.parse(dateController.text);
      String timeStr = timeController.text;
      List<String> timeParts = timeStr.split(':');
      date = DateTime(date.year, date.month, date.day, int.parse(timeParts[0]),
          int.parse(timeParts[1]));

      if (widget.transactionId != null) {
        await firestoreService.updateTransaction(
          widget.transactionId!,
          descriptionController.text,
          amount.toInt(),
          date,
          selectedCategoryId!,
          type,
        );
      } else {
        await firestoreService.addTransaction(
          descriptionController.text,
          amount.toInt(),
          date,
          selectedCategoryId!,
          type,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transaksi berhasil disimpan'),
        backgroundColor: Colors.green,
      ));

      Navigator.pop(context, true);
    } catch (e) {
      print("Terjadi kesalahan saat menyimpan transaksi: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan saat menyimpan transaksi: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> insertCategory(String name, int type) async {
    await categories.add({
      'name': name,
      'type': type,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
    setState(() {});
  }

  Future<void> showCategoryDialog() async {
    categoryNameController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(isExpense ? 'Kategori Pengeluaran' : 'Kategori Pendapatan'),
          content: TextFormField(
            controller: categoryNameController,
            decoration: InputDecoration(hintText: 'Nama Kategori'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (categoryNameController.text.isNotEmpty) {
                  insertCategory(categoryNameController.text, type);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Nama kategori tidak boleh kosong'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Catat Transaksi",
          style: GoogleFonts.montserrat(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isExpense = false;
                            type = 1;
                            selectedCategoryId = null; // Reset kategori
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              !isExpense ? Colors.blue : Colors.grey[300],
                          foregroundColor:
                              !isExpense ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Pendapatan"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isExpense = true;
                            type = 2;
                            selectedCategoryId = null; // Reset kategori
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isExpense ? Colors.red : Colors.grey[300],
                          foregroundColor:
                              isExpense ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Pengeluaran"),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Jumlah'),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: categories.where('type', isEqualTo: type).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Terjadi kesalahan: ${snapshot.error}'));
                  } else {
                    final items = snapshot.data?.docs.map((doc) {
                      final category = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(category['name']),
                      );
                    }).toList();
                    items?.add(DropdownMenuItem<String>(
                      value: 'add_category',
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Tambah Kategori'),
                        ],
                      ),
                    ));
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCategoryId,
                        onChanged: (String? newValue) {
                          if (newValue == 'add_category') {
                            showCategoryDialog();
                          } else {
                            setState(() {
                              selectedCategoryId = newValue;
                            });
                          }
                        },
                        hint: Text("Pilih Kategori"),
                        items: items,
                      ),
                    );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: "Tanggal"),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: timeController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Jam Transaksi'),
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        timeController.text =
                            '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: "Deskripsi"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: saveTransaction,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('Simpan Transaksi'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
