import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../../config/config.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  bool hasUppercase = false;
  bool hasSpecialCharacter = false;
  bool hasNumber = false;
  String username = '';

  @override
  void initState() {
    super.initState();
    _getUsernameFromToken();
  }

  Future<void> _getUsernameFromToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      setState(() {
        username = payload['username'];
      });
      print('Username obtenido del token: $username');
    } else {
      print('Error: Token no encontrado');
    }
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasSpecialCharacter = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Las contraseñas nuevas no coinciden")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      print("Error: No se encontró el token de autenticación.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de autenticación, intente de nuevo")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      print("Iniciando cambio de contraseña para $username...");
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}:30010/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'username': username,
          'oldPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        print("Cambio de contraseña exitoso.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Contraseña actualizada con éxito")),
        );
        Navigator.pop(context); // Regresar a la pantalla anterior
      } else {
        print("Error en el cambio de contraseña: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cambiar la contraseña")),
        );
      }
    } catch (e) {
      print("Excepción al cambiar la contraseña: $e");
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
    bool isPasswordValid = hasUppercase && hasSpecialCharacter && hasNumber;

    return Scaffold(
      appBar: AppBar(
        title: Text("Cambiar Contraseña"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _currentPasswordController,
                            decoration: InputDecoration(labelText: "Contraseña actual"),
                            obscureText: true,
                          ),
                          TextField(
                            controller: _newPasswordController,
                            decoration: InputDecoration(labelText: "Nueva contraseña"),
                            obscureText: true,
                            onChanged: _checkPasswordStrength,
                          ),
                          TextField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(labelText: "Confirmar nueva contraseña"),
                            obscureText: true,
                          ),
                          SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Requisitos de la contraseña:",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              _buildPasswordRequirement("Al menos una mayúscula", hasUppercase),
                              _buildPasswordRequirement("Al menos un número", hasNumber),
                              _buildPasswordRequirement("Al menos un caracter especial", hasSpecialCharacter),
                            ],
                          ),
                          SizedBox(height: 20),
                          _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isPasswordValid ? Colors.blue.shade700 : Colors.grey,
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: isPasswordValid ? _changePassword : null,
                                  child: Center(
                                    child: Text(
                                      "Actualizar contraseña",
                                      style: TextStyle(fontSize: 18, color: Colors.white),
                                    ),
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

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 20,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isValid ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
