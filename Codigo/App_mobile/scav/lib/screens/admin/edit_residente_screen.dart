import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';

class EditResidenteForm extends StatefulWidget {
  final Map<String, dynamic> residente;

  EditResidenteForm({required this.residente});

  @override
  _EditResidenteFormState createState() => _EditResidenteFormState();
}

class _EditResidenteFormState extends State<EditResidenteForm> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _torreController = TextEditingController();
  final TextEditingController _departamentoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Precargar los datos del residente en los campos de texto
    _nombreController.text = widget.residente['nombre'];
    _apellidoController.text = widget.residente['apellido'];
    _rutController.text = widget.residente['rut'];
    _correoController.text = widget.residente['correo'];
    _torreController.text = widget.residente['torre'].toString();
    _departamentoController.text = widget.residente['departamento'].toString();
  }

  Future<void> _updateResidente() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    final int residenteId = widget.residente['id'];
    final url = '${AppConfig.apiUrl}:30020/api/v1/residente/editar/$residenteId';

    final residenteData = {
      "rut": _rutController.text,
      "nombre": _nombreController.text,
      "apellido": _apellidoController.text,
      "correo": _correoController.text,
      "torre": int.tryParse(_torreController.text) ?? 0,
      "departamento": int.tryParse(_departamentoController.text) ?? 0,
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(residenteData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Residente actualizado exitosamente")),
        );
        Navigator.of(context).pop(); // Cierra la pantalla de edición al completar
      } else {
        print("Error al actualizar residente: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al actualizar residente")),
        );
      }
    } catch (e) {
      print("Error en la solicitud de actualización: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error en la conexión")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Residente"),
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
                      "Editar Residente",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _nombreController,
                      decoration: InputDecoration(labelText: "Nombre"),
                    ),
                    TextField(
                      controller: _apellidoController,
                      decoration: InputDecoration(labelText: "Apellido"),
                    ),
                    TextField(
                      controller: _rutController,
                      decoration: InputDecoration(labelText: "RUT"),
                    ),
                    TextField(
                      controller: _correoController,
                      decoration: InputDecoration(labelText: "Correo"),
                    ),
                    TextField(
                      controller: _torreController,
                      decoration: InputDecoration(labelText: "Torre"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _departamentoController,
                      decoration: InputDecoration(labelText: "Departamento"),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateResidente,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Actualizar Residente",
                          style: TextStyle(color: Colors.white),
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
    );
  }
}
