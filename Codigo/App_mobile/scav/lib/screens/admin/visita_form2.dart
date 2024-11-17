import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';

class FormVisita2 extends StatefulWidget {
  final int residenteId;

  const FormVisita2({Key? key, required this.residenteId}) : super(key: key);

  @override
  _FormVisita2State createState() => _FormVisita2State();
}

class _FormVisita2State extends State<FormVisita2> {
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _vehicleLicenseController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  bool _visitExists = false;
  bool _vehicleExists = false;
  int? _visitId;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken');
    });
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ),
    );
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Registro Exitoso'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el popup
              Navigator.of(context).pushNamed('/admin_home'); // Redirige al home del administrador
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLoadingDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 15),
              Text(
                "Guardando...",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _searchVisit(String rut) async {
    final url = '${AppConfig.apiUrl}:30030/api/v1/visita/buscar/$rut';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          if (data != null && data['nombre'] != null && data['apellido'] != null) {
            _visitExists = true;
            _visitId = data['id'];
            _nombreController.text = data['nombre'];
            _apellidoController.text = data['apellido'];
            _searchVehicle(_visitId!);
          } else {
            _visitExists = false;
          }
        });
      } else {
        setState(() {
          _visitExists = false;
        });
      }
    } catch (e) {
      print('Error al buscar visita: $e');
    }
  }

  Future<void> _searchVehicle(int visitId) async {
    final url = '${AppConfig.apiUrl}:30040/api/v1/vehiculo/buscarPorVisita/$visitId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          if (data != null && data['patente'] != null) {
            _vehicleExists = true;
            _vehicleLicenseController.text = data['patente'];
          } else {
            _vehicleExists = false;
          }
        });
      }
    } catch (e) {
      print('Error al buscar vehículo: $e');
    }
  }

  Future<void> _registerVehicle() async {
    final license = _vehicleLicenseController.text.trim();
    final vehicleInfoUrl = '${AppConfig.apiUrl}:30040/api/v1/vehiculo-visita/patente/$license';
    try {
      final vehicleInfoResponse = await http.get(
        Uri.parse(vehicleInfoUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (vehicleInfoResponse.statusCode == 200) {
        final vehicleData = json.decode(utf8.decode(vehicleInfoResponse.bodyBytes))['data'];
        final registerVehicleUrl = '${AppConfig.apiUrl}:30040/api/v1/vehiculo';

        final vehicleRegisterResponse = await http.post(
          Uri.parse(registerVehicleUrl),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode({
            'patente': vehicleData['patente'],
            'marca': vehicleData['marca'] ?? 'Marca no especificada',
            'modelo': vehicleData['modelo'] ?? 'Modelo no especificado',
            'residenteId': null,
            'visitaId': _visitId,
            'estacionamientoId': null,
          }),
        );

        if (vehicleRegisterResponse.statusCode == 201) {
          print('Vehículo registrado exitosamente.');
          setState(() {
            _vehicleExists = true;
          });
        } else {
          print('Error al registrar vehículo. Código de estado: ${vehicleRegisterResponse.statusCode}');
        }
      }
    } catch (e) {
      print('Error al registrar vehículo: $e');
    }
  }

  Future<void> _registerVisit() async {
    final url = '${AppConfig.apiUrl}:30030/api/v1/visita/registrar';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'rut': _rutController.text.trim(),
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        _visitId = int.parse(response.body);
        print('Visita registrada exitosamente con ID: $_visitId');
      } else {
        print('Error al registrar visita. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al registrar visita: $e');
    }
  }

  Future<void> _registerVisitRecord() async {
    final registroVisitaUrl = '${AppConfig.apiUrl}:30030/api/v1/visita/registro';
    try {
      final response = await http.post(
        Uri.parse(registroVisitaUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'visita': {'id': _visitId},
          'residente': {'id': widget.residenteId},
          'fechaVisita': _selectedDateTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final registroVisitaId = int.parse(response.body);
        await _registerAuthorization(registroVisitaId);
        _showSuccessDialog("La visita y el vehículo han sido registrados exitosamente en espera de aprobación.");
      }
    } catch (e) {
      print('Error al registrar el registro de visita: $e');
    }
  }

  Future<void> _registerAuthorization(int registroVisitaId) async {
    final autorizacionUrl = '${AppConfig.apiUrl}:30030/api/v1/visita/autorizacion';

    try {
      await http.post(
        Uri.parse(autorizacionUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'registroVisita': {'id': registroVisitaId},
          'estado': 'Pendiente',
          'fechaAutorizacion': DateTime.now().toIso8601String(),
          'autorizadoPreviamente': false,
        }),
      );
    } catch (e) {
      print('Error al registrar autorización: $e');
    }
  }

  Future<void> _saveVisit() async {
    await _showLoadingDialog();

    if (!_visitExists) {
      await _registerVisit();

      if (_visitId == null) {
        Navigator.pop(context);
        await _showErrorDialog("Error al registrar la visita. Por favor, inténtelo de nuevo.");
        return;
      }
    }

    if (!_vehicleExists) {
      await _registerVehicle();

      if (!_vehicleExists) {
        Navigator.pop(context);
        await _showErrorDialog("La patente ya está vinculada a otra visita o residente.");
        return;
      }
    }

    if (_visitExists || _visitId != null) {
      await _registerVisitRecord();
      Navigator.pop(context);
      await _showSuccessDialog("La visita y el vehículo han sido registrados exitosamente.");
    } else {
      Navigator.pop(context);
      await _showErrorDialog("Hubo un problema al completar el registro de la visita. Inténtelo nuevamente.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles de la Visita"),
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
                        "Información de la Visita",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _rutController,
                        decoration: InputDecoration(labelText: "RUT", prefixIcon: Icon(Icons.person)),
                        onChanged: (value) {
                          if (value.isNotEmpty) _searchVisit(value);
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(labelText: "Nombre", prefixIcon: Icon(Icons.person)),
                        readOnly: _visitExists,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _apellidoController,
                        decoration: InputDecoration(labelText: "Apellido", prefixIcon: Icon(Icons.person)),
                        readOnly: _visitExists,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _vehicleLicenseController,
                        decoration: InputDecoration(labelText: "Patente", prefixIcon: Icon(Icons.directions_car)),
                        readOnly: _visitExists, // Bloquear si la visita existe
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveVisit,
                        child: Text("Guardar"),
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
