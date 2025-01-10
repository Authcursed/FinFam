import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculatorTemperaturePage extends StatefulWidget {
  const CalculatorTemperaturePage({Key? key}) : super(key: key);

  @override
  _CalculatorTemperaturePageState createState() =>
      _CalculatorTemperaturePageState();
}

class _CalculatorTemperaturePageState extends State<CalculatorTemperaturePage> {
  final TextEditingController _temperatureController = TextEditingController();
  double? result;
  String fromScale = 'Celsius'; // Default skala asal
  String toScale = 'Fahrenheit'; // Default skala tujuan

  // Fungsi untuk menghitung konversi suhu
  void calculateConversion() {
    if (_temperatureController.text.isEmpty) {
      showErrorDialog('Silakan masukkan suhu yang ingin dikonversi.');
      return;
    }

    double inputTemperature =
        double.tryParse(_temperatureController.text) ?? -1;
    if (inputTemperature == -1) {
      showErrorDialog('Masukkan suhu yang valid.');
      return;
    }

    setState(() {
      // Konversi suhu berdasarkan skala
      if (fromScale == 'Celsius') {
        if (toScale == 'Fahrenheit') {
          result = (inputTemperature * 9 / 5) + 32;
        } else if (toScale == 'Kelvin') {
          result = inputTemperature + 273.15;
        } else if (toScale == 'Reamur') {
          result = inputTemperature * 4 / 5;
        }
      } else if (fromScale == 'Fahrenheit') {
        if (toScale == 'Celsius') {
          result = (inputTemperature - 32) * 5 / 9;
        } else if (toScale == 'Kelvin') {
          result = (inputTemperature - 32) * 5 / 9 + 273.15;
        } else if (toScale == 'Reamur') {
          result = (inputTemperature - 32) * 4 / 9;
        }
      } else if (fromScale == 'Kelvin') {
        if (toScale == 'Celsius') {
          result = inputTemperature - 273.15;
        } else if (toScale == 'Fahrenheit') {
          result = (inputTemperature - 273.15) * 9 / 5 + 32;
        } else if (toScale == 'Reamur') {
          result = (inputTemperature - 273.15) * 4 / 5;
        }
      } else if (fromScale == 'Reamur') {
        if (toScale == 'Celsius') {
          result = inputTemperature * 5 / 4;
        } else if (toScale == 'Fahrenheit') {
          result = (inputTemperature * 9 / 4) + 32;
        } else if (toScale == 'Kelvin') {
          result = (inputTemperature * 5 / 4) + 273.15;
        }
      }
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
          "Konversi Suhu",
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
            // Input suhu
            TextField(
              controller: _temperatureController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Masukkan suhu ($fromScale)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown untuk memilih skala suhu asal dan tujuan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: fromScale,
                  items: ['Celsius', 'Fahrenheit', 'Kelvin', 'Reamur']
                      .map((scale) {
                    return DropdownMenuItem<String>(
                      value: scale,
                      child: Text(scale),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      fromScale = value!;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, size: 32),
                  onPressed: () {
                    setState(() {
                      // Tukar skala suhu asal dan tujuan
                      String temp = fromScale;
                      fromScale = toScale;
                      toScale = temp;
                    });
                  },
                ),
                DropdownButton<String>(
                  value: toScale,
                  items: ['Celsius', 'Fahrenheit', 'Kelvin', 'Reamur']
                      .map((scale) {
                    return DropdownMenuItem<String>(
                      value: scale,
                      child: Text(scale),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      toScale = value!;
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

            // Hasil konversi
            if (result != null)
              Card(
                elevation: 5,
                margin: const EdgeInsets.only(top: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Hasil: ${result!.toStringAsFixed(2)} $toScale',
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
