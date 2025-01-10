import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorScientific extends StatefulWidget {
  const CalculatorScientific({Key? key}) : super(key: key);

  @override
  _CalculatorScientificState createState() => _CalculatorScientificState();
}

class _CalculatorScientificState extends State<CalculatorScientific> {
  String input = ''; // Menyimpan input yang dimasukkan pengguna
  String result = '0'; // Menyimpan hasil perhitungan

  // Fungsi untuk menambahkan input
  void appendInput(String value) {
    setState(() {
      input += value;
    });
  }

  // Fungsi untuk menghitung hasil perhitungan
  void calculateResult() {
    try {
      if (input.isEmpty) return;

      // Gantilah simbol 'x' dan '÷' ke '*' dan '/' untuk operasi
      String evalInput = input.replaceAll('x', '*').replaceAll('÷', '/');

      // Menangani fungsi matematika seperti sin, cos, tan, sqrt
      evalInput = evalInput.replaceAllMapped(
          RegExp(r'√(\d+(\.\d+)?)'), (Match m) => 'sqrt(${m.group(1)})');

      evalInput = evalInput.replaceAllMapped(
        RegExp(r'(sin|cos|tan)\(([^)]+)\)'),
        (match) {
          String function = match.group(1)!;
          String angle = match.group(2)!;
          double radians = double.parse(angle) * (3.141592653589793 / 180);
          return '$function($radians)';
        },
      );

      Parser parser = Parser();
      Expression exp = parser.parse(evalInput);
      ContextModel cm = ContextModel();
      double evalResult = exp.evaluate(EvaluationType.REAL, cm);

      result = evalResult.toStringAsFixed(2);
      if (result.endsWith('.00')) {
        result = result.substring(0, result.length - 3);
      }
    } catch (e) {
      result = 'Error';
    }
    setState(() {});
  }

  // Fungsi untuk menghapus input
  void clearInput() {
    setState(() {
      input = '';
      result = '0';
    });
  }

  // Fungsi untuk menghapus karakter terakhir dari input
  void deleteLast() {
    if (input.isNotEmpty) {
      setState(() {
        input = input.substring(0, input.length - 1);
      });
    }
  }

  // Menambahkan fungsi trigonometrik ke input
  void addTrigFunction(String func) {
    setState(() {
      input += '$func(';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kalkulator Ilmiah",
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Menampilkan input yang dimasukkan oleh pengguna
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                input,
                style: const TextStyle(fontSize: 32, color: Colors.black),
              ),
            ),
          ),
          // Menampilkan hasil perhitungan
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                result,
                style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ),
          const Divider(color: Colors.grey),
          // Tombol-tombol kalkulator
          Expanded(
            child: Column(
              children: [
                buildButtonRow(['sin', 'cos', 'tan', '√']),
                buildButtonRow(['(', ')', 'C', '⌫']),
                buildButtonRow(['7', '8', '9', '÷']),
                buildButtonRow(['4', '5', '6', 'x']),
                buildButtonRow(['1', '2', '3', '-']),
                buildButtonRow(['0', '.', '=', '+']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membangun satu baris tombol
  Widget buildButtonRow(List<String> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.map((btn) {
        return ElevatedButton(
          onPressed: () {
            if (btn == '=') {
              calculateResult();
            } else if (btn == 'C') {
              clearInput();
            } else if (btn == '⌫') {
              deleteLast();
            } else if (btn == 'sin' || btn == 'cos' || btn == 'tan') {
              addTrigFunction(btn);
            } else {
              appendInput(btn);
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            backgroundColor: Colors.white, // Background color white
            foregroundColor: Colors.black, // Text color black
            shape: const CircleBorder(), // Make the button circular
            elevation: 8, // Shadow effect
            shadowColor: Colors.black.withOpacity(0.2), // Shadow color
          ),
          child: Text(
            btn,
            style: const TextStyle(fontSize: 24, color: Colors.black),
          ),
        );
      }).toList(),
    );
  }
}
