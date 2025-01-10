import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Untuk bekerja dengan file gambar
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Untuk menampung gambar profil yang dipilih
  File? _profileImage;
  String? _role = 'Loading...';
  String? _name = 'Loading...';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi untuk mengambil data pengguna dari Firebase
  Future<void> _getUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Ambil data nama dan role dari Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _name = userDoc['name'] ?? user.displayName ?? 'No name';
        _role = userDoc['role'] ?? 'No role';
      });
    }
  }

  // Fungsi untuk logout
  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut(); // Logout dari Firebase Authentication
      Navigator.pushReplacementNamed(context, '/login'); // Arahkan ke LoginPage
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
    }
  }

  // Fungsi untuk memilih gambar profil dari galeri atau kamera
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // Menyimpan gambar yang dipilih
      });
    }
  }

  // Fungsi untuk mengunggah gambar profil ke Firebase Storage
  Future<void> _uploadProfileImage() async {
    if (_profileImage != null) {
      try {
        String fileName = '${_auth.currentUser?.uid}_profile.jpg';
        Reference storageRef =
            FirebaseStorage.instance.ref().child('profiles/$fileName');
        await storageRef.putFile(_profileImage!);
        String downloadURL = await storageRef.getDownloadURL();

        // Update URL gambar profil di Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'profileImage': downloadURL});
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  // Fungsi untuk konfirmasi logout
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
                logout(context); // Melakukan logout
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getUserData(); // Mengambil data pengguna ketika halaman dibuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto Profil
              GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.blue.shade200,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : NetworkImage('https://via.placeholder.com/150')
                              as ImageProvider,
                    ),
                    const Positioned(
                      bottom: 10,
                      right: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Nama Pengguna
              Text(
                _name!,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Email Pengguna
              Text(
                _auth.currentUser?.email ?? 'No email',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Role Pengguna
              Text(
                'Role: $_role',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutConfirmation(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
