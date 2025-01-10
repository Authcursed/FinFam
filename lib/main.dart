import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:FinFam/services/auth_provider.dart' as app_auth_provider;
import 'package:FinFam/pages/splash_page.dart';
import 'package:FinFam/pages/login_page.dart';
import 'package:FinFam/pages/main_page.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth_provider.AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // SplashPage sebagai halaman pertama
        home: const SplashPage(),
        // Tambahkan rute navigasi
        routes: {
          '/login': (context) => const LoginPage(),
          '/main': (context) => MainPage(selectedDate: DateTime.now()),
        },
      ),
    );
  }
}
