import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculatorCurrencyPage extends StatefulWidget {
  const CalculatorCurrencyPage({super.key});

  @override
  _CalculatorCurrencyPage createState() => _CalculatorCurrencyPage();
}

class _CalculatorCurrencyPage extends State<CalculatorCurrencyPage> {
  final TextEditingController _amountController = TextEditingController();
  double? result;
  String fromCurrency = 'IDR'; // Default mata uang asal
  String toCurrency = 'USD'; // Default mata uang tujuan

  // Nilai tukar relatif terhadap USD (sebagai basis)
  final Map<String, double> baseExchangeRates = {
    'IDR': 14920.0, // 1 USD = 14920 IDR
    'USD': 1.0, // 1 USD = 1 USD
    'EUR': 0.85, // 1 USD = 0.85 EUR
    'JPY': 110.0, // 1 USD = 110 JPY
    'SAR': 3.75, // 1 USD = 3.75 SAR
    'GBP': 0.74, // 1 USD = 0.74 GBP
    'AUD': 1.34, // 1 USD = 1.34 AUD
    'CAD': 1.25, // 1 USD = 1.25 CAD
    'INR': 73.5, // 1 USD = 73.5 INR
    'CNY': 6.45, // 1 USD = 6.45 CNY
  };

  // Menghitung konversi antara mata uang apa pun
  void calculateConversion() {
    if (_amountController.text.isEmpty) {
      showErrorDialog('Silakan masukkan jumlah yang ingin dikonversi.');
      return;
    }

    double inputAmount = double.tryParse(_amountController.text) ?? -1;
    if (inputAmount <= 0) {
      showErrorDialog('Masukkan jumlah yang valid (lebih dari 0).');
      return;
    }

    setState(() {
      double fromRate = baseExchangeRates[fromCurrency] ?? 1.0;
      double toRate = baseExchangeRates[toCurrency] ?? 1.0;

      // Konversi berdasarkan nilai tukar relatif terhadap USD
      result = (inputAmount / fromRate) * toRate;
    });
  }

  // Menampilkan dialog error jika input tidak valid
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Konversi Mata Uang",
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input jumlah
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Masukkan jumlah ($fromCurrency)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown untuk memilih mata uang asal dan tujuan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: fromCurrency,
                  items: baseExchangeRates.keys.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      fromCurrency = value!;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, size: 32),
                  onPressed: () {
                    setState(() {
                      // Tukar mata uang asal dan tujuan
                      String temp = fromCurrency;
                      fromCurrency = toCurrency;
                      toCurrency = temp;
                    });
                  },
                ),
                DropdownButton<String>(
                  value: toCurrency,
                  items: baseExchangeRates.keys.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      toCurrency = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol untuk melakukan konversi
            ElevatedButton(
              onPressed: calculateConversion,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor:
                      Colors.blue, // Background color red for reset
                  foregroundColor: Colors.white),
              child: const Text('Konversi'),
            ),
            const SizedBox(height: 20),

            // Hasil konversi
            if (result != null)
              Card(
                elevation: 5,
                margin: const EdgeInsets.only(top: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Hasil: ${result!.toStringAsFixed(2)} $toCurrency',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
