import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final String apiUrl = "${AppConfig.apiUrl}:30010/auth/login";

  Future<void> _storeToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  Future<void> _login() async {
    print("Intentando iniciar sesión...");
    print("Conectándose a $apiUrl");
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': _usernameController.text,
              'passwd': _passwordController.text,
            }),
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);


        Map<String, dynamic> payload = Jwt.parseJwt(token);
        int userType = payload['role'];

        if (userType == 1) {
          Navigator.pushReplacementNamed(context, '/admin_home');
        } else if (userType == 2) {
          Navigator.pushReplacementNamed(context, '/resident_home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Credenciales incorrectas o error en el servidor")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Intente de nuevo más tarde")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // colors: [Colors.blue.shade800, Colors.blue.shade400],
            colors: [Colors.lightBlue.shade800, Colors.lightBlue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Logo de la aplicación
                  Image.asset(
                    'assets/images/logo2.png', // Ruta de la imagen
                    height: 500,
                  ),
                  SizedBox(height: 30),
                  // Tarjeta elevada para el formulario
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Bienvenido",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                           SizedBox(height: 10),
                          // TextField con ancho limitado
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 400),
                            child: TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                labelText: "Usuario",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 400),
                            child: TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock),
                                labelText: "Contraseña",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              obscureText: true,
                            ),
                          ),
                          SizedBox(height: 20), // Espaciado adicional entre contraseña y botón
                          _isLoading
                              ? CircularProgressIndicator()
                              : ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 15),
                                      ),
                                      onPressed: _login,
                                      child: Text(
                                        "Iniciar Sesión",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white, // Cambia el color de la letra a blanco
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/recover_password');
                            },
                            child: Text(
                              "¿Olvidaste tu contraseña?",
                              style: TextStyle(color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
