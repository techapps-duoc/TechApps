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
      title: const Text(
        "Administrar Visitas",
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
                  // Título: Registrar Nueva Visita
                  _buildSectionTitle("Registrar Nueva Visita"),
                  const SizedBox(height: 10),

                  // Campos de entrada
                  _buildInputField(controller: _nombreController, labelText: "Nombre", icon: Icons.person),
                  _buildInputField(controller: _apellidoController, labelText: "Apellido", icon: Icons.family_restroom),
                  _buildInputField(controller: _rutController, labelText: "RUT", icon: Icons.badge),
                  _buildInputField(controller: _motivoController, labelText: "Motivo de Visita", icon: Icons.edit_note),
                  const SizedBox(height: 20),

                  // Botón: Guardar Visita
                  Center(
                    child: ElevatedButton(
                      onPressed: _guardarVisita,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.2),
                      ),
                      child: const Text(
                        "Guardar Visita",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título: Lista de Visitas
                  _buildSectionTitle("Lista de Visitas"),
                  const SizedBox(height: 10),

                  // Lista de Visitas
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentVisits.length,
                    itemBuilder: (context, index) {
                      final visita = currentVisits[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade700,
                            child: Text(
                              visita['nombre'][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            '${visita['nombre']} ${visita['apellido']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('RUT: ${visita['rut']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  // Acción de edición
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
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
                  const SizedBox(height: 10),

                  // Paginación
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _previousPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          "Anterior",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Página ${currentPage + 1} de ${((visitas.length - 1) / itemsPerPage).ceil() + 1}',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                      ),
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          "Siguiente",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
  );
}

// Método para construir campos de entrada estilizados
Widget _buildInputField({
  required TextEditingController controller,
  required String labelText,
  required IconData icon,
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
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
    ),
  );
}

// Método para construir títulos de sección estilizados
Widget _buildSectionTitle(String title) {
  return Text(
    title,
    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
    textAlign: TextAlign.center,
  );
}

}
