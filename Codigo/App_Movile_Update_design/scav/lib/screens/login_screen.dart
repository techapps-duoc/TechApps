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
        await _storeToken(token);

        Map<String, dynamic> payload = Jwt.parseJwt(token);
        int userType = payload['role'];

        if (userType == 1) {
          Navigator.pushReplacementNamed(context, '/admin_home');
        } else if (userType == 2) {
          Navigator.pushReplacementNamed(context, '/resident_home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Credenciales incorrectas o error en el servidor")),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
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
                  // Logo de la aplicación con sombra
                  Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26, // Color de la sombra
                          blurRadius: 70, // Difusión de la sombra
                          offset: Offset(0, 9), // Desplazamiento de la sombra
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo2.png',
                      height: 260,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Tarjeta elevada para el formulario
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(20), // Bordes redondeados
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF0D47A1), // Blanco en la parte superior
                          Color(
                              0xFF42A5F5), // Transparente en la parte inferior
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4), // Sombra del contenedor
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Bienvenido",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                filled: true, // Fondo sólido
                                fillColor: Colors
                                    .white, // Color blanco para las casillas
                                prefixIcon: const Icon(Icons.person),
                                labelText: "Usuario",
                                labelStyle:
                                    TextStyle(color: Colors.blue.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                filled: true, // Fondo sólido
                                fillColor: Colors
                                    .white, // Color blanco para las casillas
                                prefixIcon: const Icon(Icons.lock),
                                labelText: "Contraseña",
                                labelStyle:
                                    TextStyle(color: Colors.blue.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              obscureText: true,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(
                                            0.9), // Sombra blanca intensa
                                        blurRadius: 60, // Difusión de la sombra
                                        spreadRadius:
                                            10, // Expansión de la sombra
                                        offset: Offset(0,
                                            10), // Desplazamiento vertical de la sombra
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 22, 107, 192), // Fondo azul
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                      ),
                                      onPressed: _login,
                                      child: const Text(
                                        "Iniciar Sesión",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/recover_password');
                            },
                            child: const Text(
                              "¿Olvidaste tu contraseña?",
                              style: TextStyle(
                                color: Colors.white, // Color del texto
                                fontWeight: FontWeight.bold, // Negrita
                                fontSize:
                                    16, // Tamaño de la fuente (puedes ajustarlo según lo necesites)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
