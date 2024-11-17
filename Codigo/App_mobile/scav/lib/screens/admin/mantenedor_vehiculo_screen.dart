import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';

class MantenedorVehiculoForm extends StatefulWidget {
  @override
  _MantenedorVehiculoFormState createState() => _MantenedorVehiculoFormState();
}

class _MantenedorVehiculoFormState extends State<MantenedorVehiculoForm> {
  List<dynamic> vehiculos = [];
  List<dynamic> currentVehicles = [];
  int currentPage = 0;
  final int itemsPerPage = 10;
  bool isLoading = true;

  // Controladores para el formulario de nuevo vehículo
  final TextEditingController _patenteController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _anioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchVehiculos();
  }

  Future<void> _fetchVehiculos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    final url = '${AppConfig.apiUrl}:30040/api/v1/vehiculos';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          vehiculos = json.decode(utf8.decode(response.bodyBytes));
          _updateCurrentPage();
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al obtener vehículos: $e");
    }
  }

  void _updateCurrentPage() {
    final start = currentPage * itemsPerPage;
    final end = start + itemsPerPage;
    currentVehicles = vehiculos.sublist(
      start,
      end > vehiculos.length ? vehiculos.length : end,
    );
  }

  void _nextPage() {
    if ((currentPage + 1) * itemsPerPage < vehiculos.length) {
      setState(() {
        currentPage++;
        _updateCurrentPage();
      });
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        _updateCurrentPage();
      });
    }
  }

  void _guardarVehiculo() {
    final patente = _patenteController.text;
    final marca = _marcaController.text;
    final modelo = _modeloController.text;
    final color = _colorController.text;
    final anio = _anioController.text;

    _patenteController.clear();
    _marcaController.clear();
    _modeloController.clear();
    _colorController.clear();
    _anioController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Vehículo guardado")),
    );

    setState(() {
      vehiculos.add({
        'patente': patente,
        'marca': marca,
        'modelo': modelo,
        'color': color,
        'anio': anio,
      });
      _updateCurrentPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Administrar Vehículos"),
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
                      // Formulario de nuevo vehículo
                      Text(
                        "Registrar Nuevo Vehículo",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _patenteController,
                        decoration: InputDecoration(labelText: "Patente"),
                      ),
                      TextField(
                        controller: _marcaController,
                        decoration: InputDecoration(labelText: "Marca"),
                      ),
                      TextField(
                        controller: _modeloController,
                        decoration: InputDecoration(labelText: "Modelo"),
                      ),
                      TextField(
                        controller: _colorController,
                        decoration: InputDecoration(labelText: "Color"),
                      ),
                      TextField(
                        controller: _anioController,
                        decoration: InputDecoration(labelText: "Año"),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _guardarVehiculo,
                          child: Text("Guardar Vehículo"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Lista de vehículos con paginación
                      Text(
                        "Lista de Vehículos",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: currentVehicles.length,
                        itemBuilder: (context, index) {
                          final vehiculo = currentVehicles[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 5,
                            child: ListTile(
                              title: Text(
                                '${vehiculo['marca']} ${vehiculo['modelo']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Patente: ${vehiculo['patente']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      // Acción de edición
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      // Acción de eliminación
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _previousPage,
                            child: Text(
                              "Anterior",
                              style: TextStyle(color: Colors.blue.shade700),
                            ),
                          ),
                          Text(
                            'Página ${currentPage + 1} de ${((vehiculos.length - 1) / itemsPerPage).ceil() + 1}',
                          ),
                          ElevatedButton(
                            onPressed: _nextPage,
                            child: Text(
                              "Siguiente",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                            ),
                          ),
                        ],
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
