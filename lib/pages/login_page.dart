import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_page.dart'; // Impor HomePage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController otherRoleController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  String? role;
  String? gender;
  bool isAgreeTerms = false;

  // Fungsi untuk login
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Login menggunakan Firebase Authentication
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Jika login berhasil, arahkan ke MainPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MainPage(selectedDate: DateTime.now()), // Tambahkan parameter
        ),
      );
    } catch (e) {
      _showError('Gagal Login: $e');
    }
  }

  // Fungsi untuk registrasi
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isAgreeTerms) {
      _showError('Please agree to the terms and conditions');
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Mengecek apakah email sudah terdaftar
      final List<String> methods =
          await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        _showError('Akun sudah dibuat. Silakan login.');
        return;
      }

      // Mendaftar pengguna baru menggunakan Firebase Authentication
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Menyimpan data tambahan ke Firestore setelah registrasi
      FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'email': email,
        'name': nameController.text,
        'role': role == 'Other' ? otherRoleController.text : role!,
        'gender': gender,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Navigasi ke halaman setelah registrasi berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MainPage(selectedDate: DateTime.now()), // Tambahkan parameter
        ),
      );
    } catch (e) {
      _showError('Gagal Mendaftar: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Judul dinamis berdasarkan status login atau register
        title: Text(
          isLogin ? 'Login' : 'Daftar',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isLogin)
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                if (!isLogin) const SizedBox(height: 20),
                if (!isLogin)
                  DropdownButtonFormField<String>(
                    // Drop down untuk role
                    value: role,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text("Choose Role"),
                    items: ['Ayah', 'Ibu', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        role = newValue;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select a role'
                        : null,
                  ),
                if (!isLogin && role == 'Other') const SizedBox(height: 20),
                if (!isLogin && role == 'Other')
                  TextFormField(
                    controller: otherRoleController,
                    decoration: const InputDecoration(
                      labelText: 'Enter role',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please specify the role'
                        : null,
                  ),
                if (!isLogin) const SizedBox(height: 20),
                TextFormField(
                  // Field untuk email
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Email is required'
                      : !RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                              .hasMatch(value)
                          ? 'Enter a valid email'
                          : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  // Field untuk password
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Password is required'
                      : null,
                ),
                if (!isLogin) const SizedBox(height: 20),
                if (!isLogin)
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'Laki-laki',
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = value;
                                });
                              },
                            ),
                            const Text('Laki-laki'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'Perempuan',
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = value;
                                });
                              },
                            ),
                            const Text('Perempuan'),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (!isLogin)
                  Row(
                    children: [
                      Checkbox(
                        value: isAgreeTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            isAgreeTerms = value ?? false;
                          });
                        },
                      ),
                      const Text('I agree to the terms and conditions'),
                    ],
                  ),
                ElevatedButton(
                  // Tombol login atau register
                  onPressed: isLogin ? _login : _register,
                  child: Text(isLogin ? 'Login' : 'Register'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(isLogin
                      ? "Don't have an account? Register"
                      : "Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
