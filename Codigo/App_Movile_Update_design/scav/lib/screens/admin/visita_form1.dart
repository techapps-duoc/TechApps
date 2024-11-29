import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scav/screens/admin/visita_form2.dart';

import '../../config/config.dart';
import 'visita_form2.dart';

class FormVisita1 extends StatefulWidget {
  @override
  _FormVisita1State createState() => _FormVisita1State();
}

class _FormVisita1State extends State<FormVisita1> {
  final TextEditingController primerNombreController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController torreController = TextEditingController();
  final TextEditingController numeroDomicilioController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  String tipoResidencia = 'departamento';
  bool residenteEncontrado = false;
  int? residenteId;

  Future<void> _buscarResidente() async {
    setState(() {
      residenteEncontrado = false;
    });

    if (torreController.text.isNotEmpty && numeroDomicilioController.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final url = '${AppConfig.apiUrl}:30020/api/v1/residente/buscar/torre/${torreController.text}/departamento/${numeroDomicilioController.text}';

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        if (response.statusCode == 200) {
          final residenteData = json.decode(utf8.decode(response.bodyBytes));
          setState(() {
            primerNombreController.text = residenteData['nombre'];
            apellidosController.text = residenteData['apellido'];
            correoController.text = residenteData['correo'];
            residenteId = residenteData['id'];
            residenteEncontrado = true;
          });
        } else {
          _mostrarMensaje("Residente no encontrado.");
        }
      } catch (e) {
        _mostrarMensaje("Error en la búsqueda del residente.");
      }
    } else {
      _mostrarMensaje("Ingrese torre y departamento.");
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!residenteEncontrado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    }
  }

  void _continuar() {
    if (residenteEncontrado && residenteId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormVisita2(residenteId: residenteId!),
        ),
      );
      setState(() {
        residenteEncontrado = false; // Reset the variable when moving to the next screen
      });
    } else {
      _mostrarMensaje("Primero busca y selecciona un residente.");
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "Registrar Visita",
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
                    // Título
                    Text(
                      "Información de Visita",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Opciones de residencia
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: 'casa',
                          groupValue: tipoResidencia,
                          onChanged: (value) {
                            setState(() {
                              tipoResidencia = value!;
                              torreController.text = '0';
                            });
                          },
                        ),
                        const Text(
                          'Casa',
                          style: TextStyle(fontSize: 16),
                        ),
                        Radio<String>(
                          value: 'departamento',
                          groupValue: tipoResidencia,
                          onChanged: (value) {
                            setState(() {
                              tipoResidencia = value!;
                              torreController.clear();
                            });
                          },
                        ),
                        const Text(
                          'Departamento',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Campos de Torre y Número de Domicilio
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: torreController,
                            hintText: 'Torre',
                            labelText: 'Torre',
                            icon: Icons.apartment,
                            enabled: tipoResidencia == 'departamento',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInputField(
                            controller: numeroDomicilioController,
                            hintText: 'Número Domicilio',
                            labelText: 'Número Domicilio',
                            icon: Icons.format_list_numbered,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Campos de Nombre, Apellido y Correo
                    _buildInputField(
                      controller: primerNombreController,
                      hintText: 'Nombre',
                      labelText: 'Nombre',
                      icon: Icons.person,
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      controller: apellidosController,
                      hintText: 'Apellido',
                      labelText: 'Apellido',
                      icon: Icons.family_restroom,
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      controller: correoController,
                      hintText: 'Correo',
                      labelText: 'Correo',
                      icon: Icons.email,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),

                    // Botón de Continuar
                    Center(
                      child: ElevatedButton(
                        onPressed: _continuar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        child: const Text(
                          "Continuar",
                          style: TextStyle(
                            color: Colors.white,
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
          ),
        ),
      ),
    ),
  );
}

// Método reutilizable para construir campos de entrada con sombra y bordes redondeados
Widget _buildInputField({
  required TextEditingController controller,
  required String hintText,
  required String labelText,
  required IconData icon,
  bool enabled = true,
  bool readOnly = false,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
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
    child: TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      style: const TextStyle(fontSize: 16),
    ),
  );
}

}
