import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';
import 'package:jwt_decode/jwt_decode.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  @override
  _EditPersonalInfoScreenState createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _torreController = TextEditingController();
  final TextEditingController _departamentoController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserDataFromToken();
  }

  Future<void> _getUserDataFromToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      setState(() {
        _idController.text = payload['id'].toString();
        _rutController.text = payload['rut'];
        _nombreController.text = payload['nombre'];
        _apellidoController.text = payload['apellido'];
        _emailController.text = payload['correo'];
        _torreController.text = payload['torre'].toString();
        _departamentoController.text = payload['departamento'].toString();
      });
    } else {
      print('Error: Token no encontrado');
    }
  }

  Future<void> _updateEmail() async {
    if (!_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ingrese un correo electrónico válido")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    try {
      final response = await http.put(
        Uri.parse('${AppConfig.apiUrl}:30020/api/v1/residente/editar/${_idController.text}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'id': int.parse(_idController.text),
          'rut': _rutController.text,
          'nombre': _nombreController.text,
          'apellido': _apellidoController.text,
          'correo': _emailController.text,
          'torre': int.parse(_torreController.text),
          'departamento': int.parse(_departamentoController.text),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Correo actualizado con éxito")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al actualizar el correo")),
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

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Editar Información Personal",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),),
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
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildReadOnlyField("ID", _idController),
                      _buildReadOnlyField("RUT", _rutController),
                      _buildReadOnlyField("Nombre", _nombreController),
                      _buildReadOnlyField("Apellido", _apellidoController),
                      _buildReadOnlyField("Torre", _torreController),
                      _buildReadOnlyField(
                          "Departamento", _departamentoController),
                      const SizedBox(height: 20),
                      _buildEditableField(
                          "Correo Electrónico", _emailController),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 10,
                                shadowColor: Colors.black.withOpacity(0.2),
                              ),
                              onPressed: _updateEmail,
                              child: const Text(
                                "Actualizar Correo",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Colors.blue.shade700,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    ),
  );
}

Widget _buildEditableField(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          prefixIcon: Icon(
            Icons.email_outlined,
            color: Colors.blue.shade700,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        keyboardType: TextInputType.emailAddress,
      ),
    ),
  );
}
}
