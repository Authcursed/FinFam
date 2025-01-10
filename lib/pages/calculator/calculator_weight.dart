import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculatorWeight extends StatefulWidget {
  const CalculatorWeight({Key? key}) : super(key: key);

  @override
  _CalculatorWeightState createState() => _CalculatorWeightState();
}

class _CalculatorWeightState extends State<CalculatorWeight> {
  // Nilai input berat dan satuan yang dipilih
  TextEditingController inputController = TextEditingController();
  String fromUnit = 'kg'; // Satuan asal (default kg)
  String toUnit = 'lb'; // Satuan tujuan (default lb)
  String result = ''; // Hasil konversi

  // Daftar satuan berat yang tersedia
  List<String> units = ['kg', 'g', 'lb', 'oz', 'ton'];

  // Fungsi untuk mengonversi berat
  double convertWeight(double value, String fromUnit, String toUnit) {
    double inKg = value;

    // Mengonversi input ke kilogram (kg) terlebih dahulu
    if (fromUnit == 'g') {
      inKg = value / 1000; // gram ke kilogram
    } else if (fromUnit == 'lb') {
      inKg = value * 0.453592; // pound ke kilogram
    } else if (fromUnit == 'oz') {
      inKg = value * 0.0283495; // ons ke kilogram
    } else if (fromUnit == 'ton') {
      inKg = value * 1000; // ton ke kilogram
    }

    // Mengonversi dari kilogram ke satuan tujuan
    double result = inKg; // Default jika toUnit adalah kg
    if (toUnit == 'g') {
      result = inKg * 1000; // kilogram ke gram
    } else if (toUnit == 'lb') {
      result = inKg / 0.453592; // kilogram ke pound
    } else if (toUnit == 'oz') {
      result = inKg / 0.0283495; // kilogram ke ons
    } else if (toUnit == 'ton') {
      result = inKg / 1000; // kilogram ke ton
    }

    return result;
  }

  // Fungsi untuk melakukan konversi dan menampilkan hasil
  void convert() {
    setState(() {
      double input = double.tryParse(inputController.text) ?? 0;
      result = input == 0
          ? 'Masukkan nilai berat yang valid'
          : '${convertWeight(input, fromUnit, toUnit).toStringAsFixed(2)} $toUnit';
    });
  }

  // Fungsi untuk mereset kalkulator
  void reset() {
    setState(() {
      inputController.clear();
      result = '';
      fromUnit = 'kg';
      toUnit = 'lb';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Konversi Berat",
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
            // Input text field untuk berat
            TextField(
              controller: inputController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Masukkan Berat',
                hintText: 'Contoh: 10',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Pilihan satuan asal (from unit)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dari Satuan:'),
                DropdownButton<String>(
                  value: fromUnit,
                  onChanged: (String? newValue) {
                    setState(() {
                      fromUnit = newValue!;
                    });
                  },
                  items: units.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Pilihan satuan tujuan (to unit)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ke Satuan:'),
                DropdownButton<String>(
                  value: toUnit,
                  onChanged: (String? newValue) {
                    setState(() {
                      toUnit = newValue!;
                    });
                  },
                  items: units.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol untuk melakukan konversi
            ElevatedButton(
              onPressed: convert,
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

            // Tombol untuk reset kalkulator
            ElevatedButton(
              onPressed: reset,
              child: const Text('Reset'),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Colors.red, // Background color red for reset
                  foregroundColor: Colors.white),
            ),
            const SizedBox(height: 20),
            // Menampilkan hasil konversi
            Text(
              result,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
