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
      title: const Text(
        "Administrar Vehículos",
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
                  // Título: Registrar Nuevo Vehículo
                  _buildSectionTitle("Registrar Nuevo Vehículo"),
                  const SizedBox(height: 10),

                  // Campos de entrada estilizados
                  _buildInputField(
                      controller: _patenteController,
                      labelText: "Patente",
                      icon: Icons.badge),
                  _buildInputField(
                      controller: _marcaController,
                      labelText: "Marca",
                      icon: Icons.car_repair),
                  _buildInputField(
                      controller: _modeloController,
                      labelText: "Modelo",
                      icon: Icons.model_training),
                  _buildInputField(
                      controller: _colorController,
                      labelText: "Color",
                      icon: Icons.color_lens),
                  _buildInputField(
                      controller: _anioController,
                      labelText: "Año",
                      icon: Icons.calendar_today,
                      isNumeric: true),
                  const SizedBox(height: 20),

                  // Botón: Guardar Vehículo
                  Center(
                    child: ElevatedButton(
                      onPressed: _guardarVehiculo,
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
                        "Guardar Vehículo",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título: Lista de Vehículos
                  _buildSectionTitle("Lista de Vehículos"),
                  const SizedBox(height: 10),

                  // Lista de Vehículos
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentVehicles.length,
                    itemBuilder: (context, index) {
                      final vehiculo = currentVehicles[index];

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
                              vehiculo['marca'][0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            '${vehiculo['marca']} ${vehiculo['modelo']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Patente: ${vehiculo['patente']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () {
                                  // Acción de edición
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
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
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Página ${currentPage + 1} de ${((vehiculos.length - 1) / itemsPerPage).ceil() + 1}',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade700),
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
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
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

// Método para construir un campo de texto estilizado
Widget _buildInputField({
  required TextEditingController controller,
  required String labelText,
  required IconData icon,
  bool isNumeric = false, // Este es el parámetro opcional que define el comportamiento.
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
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
    ),
  );
}


// Método para construir títulos de sección estilizados
Widget _buildSectionTitle(String title) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.blue.shade700,
    ),
    textAlign: TextAlign.center,
  );
}


}
