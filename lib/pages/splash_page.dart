import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FinFam/pages/main_page.dart';
import 'package:FinFam/pages/login_page.dart';
import 'package:FinFam/pages/profile_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    await Future.delayed(const Duration(seconds: 3)); // Efek splash

    if (!mounted) return;

    if (user != null) {
      // Periksa apakah pengguna memiliki profil di Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Jika profil lengkap, arahkan ke MainPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(selectedDate: DateTime.now()),
          ),
        );
      } else {
        // Jika profil belum lengkap, arahkan ke ProfilePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
          ),
        );
      }
    } else {
      // Jika belum login, arahkan ke LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Warna latar belakang splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menampilkan logo aplikasi
            Image.asset(
              'assets/logo.png',
              width: 250, // Ukuran logo
              height: 250, // Ukuran logo
            ),
            const SizedBox(
                height: 20), // Spasi antara logo dan indikator loading
            const CircularProgressIndicator(), // Indikator loading
          ],
        ),
      ),
    );
  }
}
