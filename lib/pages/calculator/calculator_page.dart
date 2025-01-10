import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:FinFam/pages/calculator/calculator_currency.dart';
import 'package:FinFam/pages/calculator/calculator_Scientific.dart';
import 'package:FinFam/pages/calculator/calculator_shapes.dart';
import 'package:FinFam/pages/calculator/calculator_temperature.dart';
import 'package:FinFam/pages/calculator/calculator_weight.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kalkulator",
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Tombol Kalkulator Scientific
            _buildCalculatorButton(
              context,
              'Kalkulator Ilmiah',
              Icons.calculate,
              Colors.blueAccent,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalculatorScientific()),
                );
              },
            ),
            const SizedBox(height: 20),

            // Tombol Konversi Suhu
            _buildCalculatorButton(
              context,
              'Konversi Suhu',
              Icons.thermostat_outlined,
              Colors.orange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalculatorTemperaturePage()),
                );
              },
            ),
            const SizedBox(height: 20),

            // Tombol Konversi Mata Uang
            _buildCalculatorButton(
              context,
              'Konversi Mata Uang',
              Icons.attach_money,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalculatorCurrencyPage()),
                );
              },
            ),
            const SizedBox(height: 20),

            // Tombol Konversi Berat
            _buildCalculatorButton(
              context,
              'Konversi Berat',
              Icons.fitness_center,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalculatorWeight()),
                );
              },
            ),
            const SizedBox(height: 20),

            // Tombol Kalkulator Bangun Ruang
            _buildCalculatorButton(
              context,
              'Kalkulator Bangun Ruang',
              Icons.architecture,
              Colors.teal,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalculatorShapesPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membangun tombol dengan icon dan teks
  Widget _buildCalculatorButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    Function onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: () => onPressed(),
      icon: Icon(icon, size: 30, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
    );
  }
}
