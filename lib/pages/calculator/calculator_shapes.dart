import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculatorShapesPage extends StatefulWidget {
  const CalculatorShapesPage({super.key});

  @override
  _CalculatorShapesPageState createState() => _CalculatorShapesPageState();
}

class _CalculatorShapesPageState extends State<CalculatorShapesPage> {
  final TextEditingController _input1Controller = TextEditingController();
  final TextEditingController _input2Controller = TextEditingController();
  final TextEditingController _input3Controller = TextEditingController();
  double? result;
  String selectedShape = 'AreaPersegi'; // Default value for area calculation
  String calculationType = 'Luas'; // Default calculation type

  final List<Map<String, dynamic>> areaShapes = [
    {'name': 'Persegi', 'icon': Icons.crop_square, 'value': 'AreaPersegi'},
    {
      'name': 'Persegi Panjang',
      'icon': Icons.view_array,
      'value': 'AreaPersegiPanjang'
    },
    {'name': 'Lingkaran', 'icon': Icons.circle, 'value': 'AreaLingkaran'},
    {
      'name': 'Layang-Layang',
      'icon': Icons.diamond,
      'value': 'AreaLayangLayang'
    },
    {'name': 'Trapesium', 'icon': Icons.architecture, 'value': 'AreaTrapesium'},
    {
      'name': 'Jajargenjang',
      'icon': Icons.category,
      'value': 'AreaJajargenjang'
    },
    {'name': 'Segitiga', 'icon': Icons.terrain, 'value': 'AreaSegitiga'},
  ];

  final List<Map<String, dynamic>> volumeShapes = [
    {'name': 'Kubus', 'icon': FontAwesomeIcons.cube, 'value': 'VolumeKubus'},
    {'name': 'Balok', 'icon': Icons.view_module, 'value': 'VolumeBalok'},
    {'name': 'Bola', 'icon': Icons.sports_baseball, 'value': 'VolumeBola'},
    {
      'name': 'Tabung',
      'icon': Icons.filter_tilt_shift,
      'value': 'VolumeTabung'
    },
    {
      'name': 'Limas Persegi',
      'icon': Icons.architecture,
      'value': 'VolumeLimasPersegi'
    },
    {
      'name': 'Kerucut',
      'icon': FontAwesomeIcons.campground,
      'value': 'VolumeKerucut'
    },
    {
      'name': 'Prisma Segitiga',
      'icon': Icons.change_circle,
      'value': 'VolumePrismaSegitiga'
    },
    {
      'name': 'Limas Segitiga',
      'icon': Icons.terrain,
      'value': 'VolumeLimasSegitiga'
    },
  ];

  void calculateArea() {
    double? input1 = double.tryParse(_input1Controller.text);
    double? input2 = double.tryParse(_input2Controller.text);

    if (input1 == null ||
        input1 <= 0 ||
        (selectedShape != 'AreaLingkaran' && (input2 == null || input2 <= 0))) {
      showErrorDialog('Masukkan nilai yang valid (lebih dari 0).');
      return;
    }

    setState(() {
      switch (selectedShape) {
        case 'AreaPersegi':
          result = input1 * input1;
          break;
        case 'AreaPersegiPanjang':
          result = input1 * input2!;
          break;
        case 'AreaLingkaran':
          result = 3.14 * input1 * input1;
          break;
        case 'AreaLayangLayang':
          result = 0.5 * input1 * input2!;
          break;
        case 'AreaTrapesium':
          result = 0.5 * (input1 + input2!) * input2;
          break;
        case 'AreaJajargenjang':
          result = input1 * input2!;
          break;
        case 'AreaSegitiga':
          result = 0.5 * input1 * input2!;
          break;
        default:
          result = 0;
      }
    });
  }

  void calculateVolume() {
    double? input1 = double.tryParse(_input1Controller.text);
    double? input2 = double.tryParse(_input2Controller.text);
    double? input3 = double.tryParse(_input3Controller.text);

    if (input1 == null ||
        input1 <= 0 ||
        (selectedShape != 'VolumeKubus' &&
            selectedShape != 'VolumeBola' &&
            (input2 == null || input2 <= 0)) ||
        (['VolumeBalok', 'VolumeTabung', 'VolumePrismaSegitiga']
                .contains(selectedShape) &&
            (input3 == null || input3 <= 0))) {
      showErrorDialog('Masukkan nilai yang valid (lebih dari 0).');
      return;
    }

    setState(() {
      switch (selectedShape) {
        case 'VolumeKubus':
          result = input1 * input1 * input1;
          break;
        case 'VolumeBalok':
          result = input1 * input2! * input3!;
          break;
        case 'VolumeBola':
          result = (4 / 3) * 3.14 * (input1 * input1 * input1);
          break;
        case 'VolumeTabung':
          result = 3.14 * (input1 * input1) * input2!;
          break;
        case 'VolumeLimasPersegi':
          result = (1 / 3) * (input1 * input1) * input2!;
          break;
        case 'VolumeKerucut':
          result = (1 / 3) * 3.14 * (input1 * input1) * input2!;
          break;
        case 'VolumePrismaSegitiga':
          result = (0.5 * input1 * input2!) * input3!;
          break;
        case 'VolumeLimasSegitiga':
          result = (1 / 3) * (0.5 * input1 * input2!) * input3!;
          break;
        default:
          result = 0;
      }
    });
  }

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
          "Kalkulator Bangun Ruang",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: 'Luas',
                    groupValue: calculationType,
                    onChanged: (value) {
                      setState(() {
                        calculationType = value!;
                        selectedShape = areaShapes.first['value'];
                        result = null;
                        _input1Controller.clear();
                        _input2Controller.clear();
                        _input3Controller.clear();
                      });
                    },
                  ),
                  const Text('Luas'),
                  Radio<String>(
                    value: 'Volume',
                    groupValue: calculationType,
                    onChanged: (value) {
                      setState(() {
                        calculationType = value!;
                        selectedShape = volumeShapes.first['value'];
                        result = null;
                        _input1Controller.clear();
                        _input2Controller.clear();
                        _input3Controller.clear();
                      });
                    },
                  ),
                  const Text('Volume'),
                ],
              ),
              DropdownButton<String>(
                value: selectedShape,
                items: (calculationType == 'Luas' ? areaShapes : volumeShapes)
                    .map((shape) {
                  return DropdownMenuItem<String>(
                    value: shape['value'],
                    child: Row(
                      children: [
                        Icon(shape['icon'], color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(shape['name']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedShape = value!;
                    _input1Controller.clear();
                    _input2Controller.clear();
                    _input3Controller.clear();
                    result = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _input1Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: calculationType == 'Luas'
                      ? 'Panjang/Jari-jari'
                      : 'Nilai 1',
                  border: const OutlineInputBorder(),
                ),
              ),
              if (selectedShape != 'AreaLingkaran' &&
                  selectedShape != 'VolumeKubus' &&
                  selectedShape != 'VolumeBola')
                const SizedBox(height: 16),
              if (selectedShape != 'AreaLingkaran' &&
                  selectedShape != 'VolumeKubus' &&
                  selectedShape != 'VolumeBola')
                TextField(
                  controller: _input2Controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nilai 2',
                    border: OutlineInputBorder(),
                  ),
                ),
              if (['VolumeBalok', 'VolumeTabung', 'VolumePrismaSegitiga']
                  .contains(selectedShape))
                const SizedBox(height: 16),
              if (['VolumeBalok', 'VolumeTabung', 'VolumePrismaSegitiga']
                  .contains(selectedShape))
                TextField(
                  controller: _input3Controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nilai 3',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    calculationType == 'Luas' ? calculateArea : calculateVolume,
                child: Text(calculationType == 'Luas'
                    ? 'Hitung Luas'
                    : 'Hitung Volume'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor:
                        Colors.blue, // Background color red for reset
                    foregroundColor: Colors.white),
              ),
              if (result != null)
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.only(top: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Hasil: ${result!.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
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
