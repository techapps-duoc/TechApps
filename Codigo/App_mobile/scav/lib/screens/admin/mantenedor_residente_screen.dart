import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scav/screens/admin/edit_residente_screen.dart';
import '../../config/config.dart';

class MantenedorResidenteForm extends StatefulWidget {
  @override
  _MantenedorResidenteFormState createState() => _MantenedorResidenteFormState();
}

class _MantenedorResidenteFormState extends State<MantenedorResidenteForm> {
  List<dynamic> residentes = [];
  List<dynamic> currentResidents = [];
  int currentPage = 0;
  final int itemsPerPage = 10;
  bool isLoading = true;

  // Controladores para el formulario de nuevo residente
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _torreController = TextEditingController();
  final TextEditingController _departamentoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchResidentes();
  }

  Future<void> _fetchResidentes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    final url = '${AppConfig.apiUrl}:30020/api/v1/residente/listar';

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
          residentes = json.decode(utf8.decode(response.bodyBytes));
          _updateCurrentPage();
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al obtener residentes: $e");
    }
  }

  void _updateCurrentPage() {
    final start = currentPage * itemsPerPage;
    final end = start + itemsPerPage;
    currentResidents = residentes.sublist(
      start,
      end > residentes.length ? residentes.length : end,
    );
  }

  void _nextPage() {
    if ((currentPage + 1) * itemsPerPage < residentes.length) {
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

 Future<void> _guardarResidente() async {
  // Datos del residente a enviar
  final residenteData = {
    "rut": _rutController.text,
    "nombre": _nombreController.text,
    "apellido": _apellidoController.text,
    "correo": _correoController.text,
    "torre": int.tryParse(_torreController.text) ?? 0,
    "departamento": int.tryParse(_departamentoController.text) ?? 0,
  };

  // URL de la API para registrar el residente
  final urlRegistrarResidente = '${AppConfig.apiUrl}:30020/api/v1/residente/registrar';

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    // Realiza la solicitud POST para registrar el residente
    final response = await http.post(
      Uri.parse(urlRegistrarResidente),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(residenteData),
    );

    if (response.statusCode == 201) {
      // Obtener el ID del residente recién registrado desde la respuesta
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      final int residenteId = responseData['id'];

      // Construye el nombre de usuario (primera letra del nombre + apellido)
      final username = '${_nombreController.text[0].toLowerCase()}${_apellidoController.text.toLowerCase()}';

      // Datos para registrar el usuario
      final userData = {
        "username": username,
        "passwd": "defaultpass",
        "residenteId": residenteId,
        "tipo": 2,
      };

      // URL de la API para registrar el usuario
      final urlRegistrarUsuario = '${AppConfig.apiUrl}:30010/auth/register';

      // Realiza la solicitud POST para registrar el usuario
      final userResponse = await http.post(
        Uri.parse(urlRegistrarUsuario),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(userData),
      );

      if (userResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Residente y usuario guardados exitosamente")),
        );

        // Agrega el nuevo residente a la lista y actualiza la página actual
        setState(() {
          residentes.add(residenteData);
          _updateCurrentPage();
        });

        // Limpia los campos del formulario
        _nombreController.clear();
        _apellidoController.clear();
        _rutController.clear();
        _correoController.clear();
        _torreController.clear();
        _departamentoController.clear();
      } else {
        print("Error al crear el usuario: ${userResponse.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al crear el usuario")),
        );
      }
      } else {
        print("Error al guardar residente: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar residente")),
        );
      }
    } catch (e) {
      print("Error en la solicitud: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error en la conexión")),
      );
    }
  }

void _eliminarResidente(String username, int residenteId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('authToken');

  // URLs para eliminar usuario y residente
  final urlEliminarUsuario = '${AppConfig.apiUrl}:30010/auth/eliminar/$username';
  final urlEliminarResidente = '${AppConfig.apiUrl}:30020/api/v1/residente/eliminar/$residenteId';

  print("Eliminando usuariio $username del residenteId $residenteId");

  try {
    // Eliminar el usuario vinculado al residente
    final userResponse = await http.delete(
      Uri.parse(urlEliminarUsuario),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (userResponse.statusCode == 200) {
      // Si la eliminación del usuario fue exitosa, eliminar el residente
      final residenteResponse = await http.delete(
        Uri.parse(urlEliminarResidente),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (residenteResponse.statusCode == 204) {
        // Actualizar la lista de residentes localmente
        setState(() {
          residentes.removeWhere((residente) => residente['id'] == residenteId);
          _updateCurrentPage();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Residente y usuario eliminados exitosamente")),
        );
      } else {
        print("Error al eliminar el residente: ${residenteResponse.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar el residente")),
        );
      }
      } else {
        print("Error al eliminar el usuario: ${userResponse.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar el usuario")),
        );
      }
    } catch (e) {
      print("Error en la eliminación: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error en la conexión")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Administrar Residentes"),
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
                      // Formulario de nuevo residente
                      Text(
                        "Registrar Nuevo Residente",
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
                          onPressed: _guardarResidente,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Guardar Residente",
                            style: TextStyle(color: Colors.white), // Asegura que el texto sea blanco
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Lista de residentes con paginación
                      Text(
                        "Lista de Residentes",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: currentResidents.length,
                        itemBuilder: (context, index) {
                          final residente = currentResidents[index];
                          final username = '${residente['nombre'][0].toLowerCase()}${residente['apellido'].toLowerCase()}';

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 5,
                            child: ListTile(
                              title: Text(
                                '${residente['nombre']} ${residente['apellido']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('RUT: ${residente['rut']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditResidenteForm(residente: residente),
                                        ),
                                      ).then((_) {
                                        _fetchResidentes(); // Actualizar la lista después de editar
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      // Código de eliminación existente
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
                            'Página ${currentPage + 1} de ${((residentes.length - 1) / itemsPerPage).ceil() + 1}',
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
