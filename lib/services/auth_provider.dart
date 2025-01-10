import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  // Memeriksa status login pengguna saat inisialisasi
  Future<void> initialize() async {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners(); // Beritahu status kepada listener
  }

  // Melakukan logout
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }
}
