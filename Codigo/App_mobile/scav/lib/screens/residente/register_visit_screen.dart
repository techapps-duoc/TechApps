import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import '../../config/config.dart';

class RegisterVisitScreen extends StatefulWidget {
  final String rut;
  RegisterVisitScreen({required this.rut});

  @override
  _RegisterVisitScreenState createState() => _RegisterVisitScreenState();
}

class _RegisterVisitScreenState extends State<RegisterVisitScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _vehicleLicenseController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  String _fechaSeleccionada = 'Seleccionar Fecha y Hora de la Visita'; // Definimos la variable para mostrar la fecha seleccionada
  bool _visitExists = false;
  bool _vehicleExists = false;
  int? _visitId;
  int? _residenteId;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndSearchVisit();
  }

  Future<void> _loadTokenAndSearchVisit() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('authToken');

  if (token != null) {
    Map<String, dynamic> payload = Jwt.parseJwt(token);
    setState(() {
      _token = token; // Asignamos el token correctamente a la variable de instancia
      _residenteId = payload['id'];
    });
    print('Residente ID obtenido del token: $_residenteId');
    await _searchVisit();
  } else {
    print('Error: Token no encontrado.');
    await _showErrorDialog("Error: No se encontró el token de autenticación.");
  }
}


  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
              Navigator.pop(context); // Vuelve a la ventana anterior (residente_home)
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

  Future<void> _searchVisit() async {
    final url = '${AppConfig.apiUrl}:30030/api/v1/visita/buscar/${widget.rut}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        if (data != null && data['nombre'] != null && data['apellido'] != null) {
          setState(() {
            _visitExists = true;
            _visitId = data['id'];
            _nombreController.text = data['nombre'];
            _apellidoController.text = data['apellido'];
          });
          await _searchVehicle(_visitId!);
        } else {
          setState(() {
            _visitExists = false;
          });
        }
      } else {
        setState(() {
          _visitExists = false;
        });
      }
    } catch (e) {
      print('Error al buscar visita: $e');
    }
  }

  Future<void> _searchVehicle(int visitaId) async {
    final url = '${AppConfig.apiUrl}:30040/api/v1/vehiculo/buscarPorVisita/$visitaId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        if (data != null && data['patente'] != null) {
          setState(() {
            _vehicleExists = true;
            _vehicleLicenseController.text = data['patente'];
          });
        } else {
          setState(() {
            _vehicleExists = false;
          });
        }
      } else {
        setState(() {
          _vehicleExists = false;
        });
      }
    } catch (e) {
      setState(() {
        _vehicleExists = false;
      });
    }
  }

  Future<void> _registerVisit() async {
    final url = '${AppConfig.apiUrl}:30030/api/v1/visita/registrar';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: json.encode({
          'rut': widget.rut,
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

  Future<void> _registerVehicle() async {
  final license = _vehicleLicenseController.text.trim();
  final vehicleCheckUrl = '${AppConfig.apiUrl}:30040/api/v1/vehiculo/patente/$license';

  try {
    // Verificar si el vehículo ya existe en la base de datos
    final vehicleCheckResponse = await http.get(
      Uri.parse(vehicleCheckUrl),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

    if (vehicleCheckResponse.statusCode == 200) {
      final data = json.decode(utf8.decode(vehicleCheckResponse.bodyBytes));

      if ((data['visitaId'] != null && data['visitaId'] != _visitId) ||
          (data['residenteId'] != null && data['residenteId'] != _residenteId)) {
        await _showErrorDialog('La patente está vinculada a otra visita o residente. No se puede registrar esta visita.');
        return;
      } else if (data['visitaId'] == _visitId) {
        print('El vehículo con la patente $license ya está registrado para esta visita.');
        setState(() {
          _vehicleExists = true;
        });
        return;
      }
    } else if (vehicleCheckResponse.statusCode == 404) {
      // Registrar el vehículo solo si la visita ya tiene un ID
      if (_visitId != null) {
        final vehicleInfoUrl = '${AppConfig.apiUrl}:30040/api/v1/vehiculo-visita/patente/$license';
        final vehicleInfoResponse = await http.get(
          Uri.parse(vehicleInfoUrl),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json; charset=UTF-8'
          },
        );

        if (vehicleInfoResponse.statusCode == 200) {
          final data = json.decode(utf8.decode(vehicleInfoResponse.bodyBytes))['data'];
          final registerVehicleUrl = '${AppConfig.apiUrl}:30040/api/v1/vehiculo';

          final vehicleRegisterResponse = await http.post(
            Uri.parse(registerVehicleUrl),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json; charset=UTF-8'
            },
            body: json.encode({
              'patente': data['patente'],
              'marca': data['marca'],
              'modelo': data['modelo'],
              'residenteId': null,
              'visitaId': _visitId,  // Asegurarse de que _visitId esté definido
              'estacionamientoId': null
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
        } else {
          print('Error al obtener datos del vehículo. Código de estado: ${vehicleInfoResponse.statusCode}');
        }
      } else {
        print("Error: No se pudo registrar el vehículo porque el ID de visita no está disponible.");
      }
    } else {
      print('Error al verificar la existencia del vehículo. Código de estado: ${vehicleCheckResponse.statusCode}');
    }
  } catch (e) {
    print('Error al registrar vehículo: $e');
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
          'residente': {'id': _residenteId},
          'fechaVisita': _selectedDateTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final registroVisitaId = int.parse(response.body);
        print('Registro de visita creado exitosamente con ID: $registroVisitaId');
        await _registerAuthorization(registroVisitaId);
      } else {
        print('Error al crear el registro de visita. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al registrar el registro de visita: $e');
    }
  }

  Future<void> _registerAuthorization(int registroVisitaId) async {
    final autorizacionUrl = '${AppConfig.apiUrl}:30030/api/v1/visita/autorizacion';

    try {
      final response = await http.post(
        Uri.parse(autorizacionUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'registroVisita': {'id': registroVisitaId},
          'estado': 'Aprobada',
          'fechaAutorizacion': _selectedDateTime.toIso8601String(),
          'autorizadoPreviamente': true,
        }),
      );

      if (response.statusCode == 201) {
        print('Autorización creada exitosamente.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Visita, vehículo, y autorización registrados exitosamente')),
        );
      } else {
        print('Error al crear la autorización. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al registrar autorización: $e');
    }
  }

  Future<void> _saveVisit() async {
    // Mostrar el diálogo de carga
    await _showLoadingDialog();

    // Registrar la visita si no existe
    if (!_visitExists) {
      await _registerVisit();

      if (_visitId == null) {
        Navigator.pop(context); // Cerrar el diálogo de carga
        await _showErrorDialog("Error al registrar la visita. Por favor, inténtelo de nuevo.");
        return;
      }
    }

    // Verificar si el vehículo ya está registrado y, si no, intentar registrarlo
    if (!_vehicleExists) {
      await _registerVehicle();

      if (!_vehicleExists) {
        Navigator.pop(context); // Cerrar el diálogo de carga
        await _showErrorDialog("La patente ya está vinculada a otra visita o residente. No se puede registrar esta visita.");
        return;
      }
    }

    // Registrar el registro de visita y autorización solo si ambos (visita y vehículo) están confirmados
    if (_visitExists || _visitId != null) {
      await _registerVisitRecord();

      // Cerrar el diálogo de carga antes de mostrar el mensaje de éxito
      Navigator.pop(context);
      await _showSuccessDialog("La visita y el vehículo han sido registrados exitosamente.");
    } else {
      Navigator.pop(context); // Cerrar el diálogo de carga
      await _showErrorDialog("Hubo un problema al completar el registro de la visita. Inténtelo nuevamente.");
    }
  }



@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Registrar Visita'),
      backgroundColor: Colors.lightBlue.shade800,
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
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _visitExists ? "Visita Encontrada" : "Registrar Nueva Visita",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      readOnly: _visitExists, // Establecer como solo lectura si la visita existe
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _apellidoController,
                      decoration: InputDecoration(
                        labelText: 'Apellido',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      readOnly: _visitExists, // Establecer como solo lectura si la visita existe
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _vehicleLicenseController,
                      decoration: InputDecoration(
                        labelText: 'Patente del Vehículo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      readOnly: _visitExists,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 10),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDateTime,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                              );
                              if (time != null) {
                                setState(() {
                                  _selectedDateTime = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                  _fechaSeleccionada = 'Visita: ${date.year}-${date.month}-${date.day} ${time.format(context)}';
                                });
                              }
                            }
                          },
                          child: Text(
                            _fechaSeleccionada,
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveVisit,
                      child: Text(
                        'Guardar Visita',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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