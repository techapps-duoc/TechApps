
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

//---modelado.-----------------------
class Residente {
  final int id;
  final String rut;
  final String nombre;
  final String apellido;
  final String correo;
  final int torre;
  final int departamento;

  Residente({
    required this.id,
    required this.rut,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.torre,
    required this.departamento,
  });

  factory Residente.fromJson(Map<String, dynamic> json) {
    return Residente(
      id: json['id'],
      rut: json['rut'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      correo: json['correo'],
      torre: json['torre'],
      departamento: json['departamento'],
    );
  }
}
//------ fin modelado------------------------------



//funciones http de busqueda-------------------------------------

Future<Residente?> buscarResidentePorRut(String rut) async {
  final url = Uri.parse('http://localhost:8081/api/v1/residente/rut/$rut'); // Reemplaza con la URL de tu API
 // 'http://localhost:8082/api/v1/vehiculo-visita/patente/$patente'
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    if (jsonData['status'] == 200) {
      return Residente.fromJson(jsonData['data']);
    } else {
      print("Residente no encontrado: ${jsonData['message']}");
      return null;
    }
  } else {
    print("Error en la solicitud: ${response.statusCode}");
    return null;
  }
}

//--------- fin metodo de busqueda--------------------------



//-------------interfaz de usuario
class BuscarResidenteScreen extends StatefulWidget {
  @override
  _BuscarResidenteScreenState createState() => _BuscarResidenteScreenState();
}

class _BuscarResidenteScreenState extends State<BuscarResidenteScreen> {
  final TextEditingController _rutController = TextEditingController();
  Residente? _residente;
  String? _mensajeError;

  Future<void> _buscarResidente() async {
    final rut = _rutController.text.trim();
    final residente = await buscarResidentePorRut(rut);

    setState(() {
      _residente = residente;
      _mensajeError = residente == null ? 'Residente no encontrado.' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Residente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _rutController,
              decoration: const InputDecoration(labelText: 'Ingrese RUT'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _buscarResidente,
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 20),
            _mensajeError != null
                ? Text(_mensajeError!, style: const TextStyle(color: Colors.red))
                : _residente != null
                    ? _mostrarDatosResidente(_residente!)
                    : const Text('Introduce un RUT para buscar.'),
          ],
        ),
      ),
    );
  }

  Widget _mostrarDatosResidente(Residente residente) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ID: ${residente.id}'),
        Text('RUT: ${residente.rut}'),
        Text('Nombre: ${residente.nombre} ${residente.apellido}'),
        Text('Correo: ${residente.correo}'),
        Text('Torre: ${residente.torre}'),
        Text('Departamento: ${residente.departamento}'),
      ],
    );
  }
}

// fin interfaz usuario------------------------------------