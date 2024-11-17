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
        title: Text("Registrar Visita"),
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
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Información de Visita",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
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
                          const Text('Casa'),
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
                          const Text('Departamento'),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: torreController,
                              enabled: tipoResidencia == 'departamento',
                              decoration: InputDecoration(
                                hintText: 'Torre',
                                labelText: 'Torre',
                                prefixIcon: Icon(Icons.apartment, color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (_) => _buscarResidente(),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextFormField(
                              controller: numeroDomicilioController,
                              decoration: InputDecoration(
                                hintText: 'Número Domicilio',
                                labelText: 'Número Domicilio',
                                prefixIcon: Icon(Icons.format_list_numbered, color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (_) => _buscarResidente(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: primerNombreController,
                        decoration: InputDecoration(
                          hintText: 'Nombre',
                          labelText: 'Nombre',
                          prefixIcon: Icon(Icons.person, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: apellidosController,
                        decoration: InputDecoration(
                          hintText: 'Apellido',
                          labelText: 'Apellido',
                          prefixIcon: Icon(Icons.family_restroom, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: correoController,
                        decoration: InputDecoration(
                          hintText: 'Correo',
                          labelText: 'Correo',
                          prefixIcon: Icon(Icons.email, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: _continuar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Continuar",
                            style: TextStyle(color: Colors.white, fontSize: 18),
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
}
