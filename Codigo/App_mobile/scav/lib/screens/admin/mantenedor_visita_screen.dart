import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';

class MantenedorVisitaForm extends StatefulWidget {
  @override
  _MantenedorVisitaFormState createState() => _MantenedorVisitaFormState();
}

class _MantenedorVisitaFormState extends State<MantenedorVisitaForm> {
  List<dynamic> visitas = [];
  List<dynamic> currentVisits = [];
  int currentPage = 0;
  final int itemsPerPage = 10;
  bool isLoading = true;

  // Controladores para el formulario de nueva visita
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController(); // Ejemplo de campo extra

  @override
  void initState() {
    super.initState();
    _fetchVisitas();
  }

  Future<void> _fetchVisitas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    final url = '${AppConfig.apiUrl}:30030/api/v1/visita/listar';

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
          visitas = json.decode(utf8.decode(response.bodyBytes));
          _updateCurrentPage();
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al obtener visitas: $e");
    }
  }

  void _updateCurrentPage() {
    final start = currentPage * itemsPerPage;
    final end = start + itemsPerPage;
    currentVisits = visitas.sublist(
      start,
      end > visitas.length ? visitas.length : end,
    );
  }

  void _nextPage() {
    if ((currentPage + 1) * itemsPerPage < visitas.length) {
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

  void _guardarVisita() {
    final nombre = _nombreController.text;
    final apellido = _apellidoController.text;
    final rut = _rutController.text;
    final motivo = _motivoController.text;

    _nombreController.clear();
    _apellidoController.clear();
    _rutController.clear();
    _motivoController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Visita guardada")),
    );

    setState(() {
      visitas.add({
        'nombre': nombre,
        'apellido': apellido,
        'rut': rut,
        'motivo': motivo,
      });
      _updateCurrentPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Administrar Visitas"),
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
                      // Formulario de nueva visita
                      Text(
                        "Registrar Nueva Visita",
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
                        controller: _motivoController,
                        decoration: InputDecoration(labelText: "Motivo de Visita"),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _guardarVisita,
                          child: Text("Guardar Visita"),
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
                      // Lista de visitas con paginación
                      Text(
                        "Lista de Visitas",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: currentVisits.length,
                        itemBuilder: (context, index) {
                          final visita = currentVisits[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 5,
                            child: ListTile(
                              title: Text(
                                '${visita['nombre']} ${visita['apellido']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('RUT: ${visita['rut']}'),
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
                            'Página ${currentPage + 1} de ${((visitas.length - 1) / itemsPerPage).ceil() + 1}',
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
