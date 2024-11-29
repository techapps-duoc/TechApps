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
      title: const Text(
        "Cambiar Contraseña",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),
      backgroundColor: Colors.blue.shade700,
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
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo: Contraseña actual
                    _buildInputField(
                      controller: _currentPasswordController,
                      labelText: "Contraseña actual",
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 15),

                    // Campo: Nueva contraseña
                    _buildInputField(
                      controller: _newPasswordController,
                      labelText: "Nueva contraseña",
                      icon: Icons.vpn_key,
                      obscureText: true,
                      onChanged: _checkPasswordStrength,
                    ),
                    const SizedBox(height: 15),

                    // Campo: Confirmar contraseña
                    _buildInputField(
                      controller: _confirmPasswordController,
                      labelText: "Confirmar nueva contraseña",
                      icon: Icons.check_circle,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    // Requisitos de contraseña
                    Text(
                      "Requisitos de la contraseña:",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    _buildPasswordRequirement("Al menos una mayúscula", hasUppercase),
                    _buildPasswordRequirement("Al menos un número", hasNumber),
                    _buildPasswordRequirement("Al menos un caracter especial", hasSpecialCharacter),
                    const SizedBox(height: 20),

                    // Botón: Actualizar contraseña
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPasswordValid ? Colors.blue.shade700 : Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.2),
                            ),
                            onPressed: isPasswordValid ? _changePassword : null,
                            child: const Center(
                              child: Text(
                                "Actualizar contraseña",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// Método para construir un campo de texto estilizado
Widget _buildInputField({
  required TextEditingController controller,
  required String labelText,
  required IconData icon,
  bool obscureText = false,
  void Function(String)? onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
    ),
  );
}

// Método para construir un indicador de requisitos de contraseña
Widget _buildPasswordRequirement(String text, bool isValid) {
  return Row(
    children: [
      Icon(
        isValid ? Icons.check_circle : Icons.cancel,
        color: isValid ? Colors.green : Colors.red,
        size: 20,
      ),
      const SizedBox(width: 8),
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
