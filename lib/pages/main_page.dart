import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:FinFam/pages/home_page.dart';
import 'package:FinFam/pages/reels_page.dart';
import 'package:FinFam/pages/chat_page.dart';
import 'package:FinFam/pages/transaction_page.dart';
import 'package:FinFam/pages/profile_page.dart';
import 'package:FinFam/pages/calculator/calculator_page.dart'; // Import Halaman Kalkulator
import 'package:FinFam/pages/phonebook_page.dart'; // Import Halaman Buku Telepon
import 'package:FinFam/pages/financial_report_page.dart'; // Import Halaman Laporan Keuangan
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainPage extends StatefulWidget {
  final DateTime selectedDate;
  const MainPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DateTime selectedDate;
  late List<Widget> _children;
  late int currentIndex;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    currentIndex = 0; // Default to HomePage
    _children = _getBottomNavigationPages(selectedDate);
  }

  // BottomNavigationBar untuk halaman utama
  List<Widget> _getBottomNavigationPages(DateTime date) {
    return [
      HomePage(selectedDate: date),
      ReelsPage(),
      ChatPageWithDrawer(),
    ];
  }

  // Drawer untuk halaman tambahan
  void _onDrawerItemSelected(int index) {
    setState(() {
      currentIndex = index;
    });
    Navigator.pop(context); // Close the drawer after item selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: currentIndex == 0,
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TransactionPage(transactionId: null),
              ),
            );
            setState(() {
              selectedDate = DateTime.now();
              _children = _getBottomNavigationPages(selectedDate);
            });
          },
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          child: Icon(Icons.add_circle),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            _children = _getBottomNavigationPages(selectedDate);
          });
        },
        type: BottomNavigationBarType.fixed, // Ensures no shifting animation
        backgroundColor: Colors.white, // Set background color
        selectedItemColor: Colors.blue, // Custom color for selected items
        unselectedItemColor: Colors.grey, // Custom color for unselected items
        selectedLabelStyle: const TextStyle(
          // Style for selected label
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          // Style for unselected label
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _children[currentIndex],
      appBar: _buildAppBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String title = '';
    if (currentIndex == 0) {
      title = "Home";
    } else if (currentIndex == 1) {
      title = "Reels";
    } else if (currentIndex == 2) {
      title = "Chat";
    }

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.blue,
      iconTheme: const IconThemeData(
        // Set drawer and icon color to white
        color: Colors.white,
      ),
      foregroundColor:
          Colors.white, // Set back button and actions icon color to white
    );
  }

  Widget _buildDrawer() {
    final currentUser = _auth.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('users').doc(currentUser?.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Center(child: Text('Error loading profile')),
                );
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final name = userData['name'] ?? 'Unknown User';
              final photoUrl = userData['photoUrl'];

              return DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                              photoUrl ?? 'https://via.placeholder.com/150'),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        currentUser?.email ?? '',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Tombol untuk halaman kalkulator
          ListTile(
            title: const Text('Kalkulator'),
            onTap: () {
              // Pastikan halaman sebelumnya ada di stack dan kembali ke main_page dengan pop
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalculatorPage()),
              );
            },
          ),
          // Tombol untuk halaman buku telepon
          ListTile(
            title: const Text('Buku Telepon'),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PhonebookPage()),
              );
            },
          ),
          // Tombol untuk halaman laporan keuangan
          ListTile(
            title: const Text('Laporan Keuangan'),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FinancialReportPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
