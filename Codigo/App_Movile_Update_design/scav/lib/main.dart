import 'package:flutter/material.dart';
import 'package:scav/screens/login_screen.dart';
import 'package:scav/screens/admin/admin_home_screen.dart';
import 'package:scav/screens/residente/resident_home_screen.dart';
import 'package:scav/screens/recover_password_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCAV App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/admin_home': (context) => AdminHomeScreen(),
        '/resident_home': (context) => ResidentHomeScreen(),
        '/recover_password': (context) => RecoverPasswordScreen(),
      },
    );
  }
}
