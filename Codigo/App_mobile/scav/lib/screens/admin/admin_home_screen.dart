import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:scav/screens/admin/change_password_screen.dart';
import 'package:scav/screens/admin/edit_personal_info.dart';
import 'package:scav/screens/admin/mantenedor_residente_screen.dart';
import 'package:scav/screens/admin/mantenedor_visita_screen.dart';
import 'package:scav/screens/admin/mantenedor_vehiculo_screen.dart';
import 'package:scav/screens/admin/visita_form1.dart';
import '../../config/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 2;
  String nombreCompleto = '';
  int torre = 0;
  int departamento = 0;
  int multasUltimoMes = 0;
  int visitasRegistradas = 0;
  
  List<dynamic> bitacoras = [];
  List<dynamic> filteredBitacoras = [];
  bool isLoading = true;

  List<dynamic> _multas = [];
  List<dynamic> _filteredMultas = [];
  TextEditingController _patenteController = TextEditingController();
  int _currentPage = 0;
  final int _pageSize = 5;

  int currentPage = 0;
  final int itemsPerPage = 10;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserDataFromToken();
    _fetchBitacoras();
  }

  Future<void> _getUserDataFromToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token != null) {
      try {
        Map<String, dynamic> payload = Jwt.parseJwt(token);
        setState(() {
          nombreCompleto = '${payload['nombre'] ?? 'Sin Nombre'} ${payload['apellido'] ?? 'Sin Apellido'}';
          torre = payload['torre'] ?? 0;
          departamento = payload['departamento'] ?? 0;
        });
      } catch (e) {
        print("Error al decodificar el token: $e");
      }
    } else {
      print("Token no encontrado.");
    }
  }

  Future<void> _fetchBitacoras() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    final url = '${AppConfig.apiUrl}:30040/api/v1/bitacoras';

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
          bitacoras = json.decode(response.body);
          filteredBitacoras = bitacoras;
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al obtener bitácoras: $e");
    }
  }

  

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    Navigator.pushReplacementNamed(context, '/');
  }

  void _filterBitacoras(String query) {
    setState(() {
      filteredBitacoras = bitacoras
          .where((bitacora) =>
              bitacora['vehiculo']['patente']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
      currentPage = 0;
    });
  }

  List<dynamic> _getCurrentPageItems() {
    final start = currentPage * itemsPerPage;
    final end = start + itemsPerPage;
    return filteredBitacoras.sublist(
      start,
      end > filteredBitacoras.length ? filteredBitacoras.length : end,
    );
  }

  Future<String?> _getResidenteIdFromToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      return payload['id'].toString();
    }
    return null;
  }

  void _nextPage() {
    if ((currentPage + 1) * itemsPerPage < filteredBitacoras.length) {
      setState(() {
        currentPage++;
      });
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        // Llama a _fetchMultas cuando seleccionas la pestaña de multas
        _fetchMultas();
      }
    });
  }

  Future<void> _fetchMultas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    String? residenteId = await _getResidenteIdFromToken();

    if (token == null || residenteId == null) {
      print("Token o Residente ID no encontrados.");
      return;
    }

    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}:30050/api/v1/multas/ultimo-mes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print('Respuesta de multas: ${response.body}');
      setState(() {
        _multas = json.decode(response.body);
        _filteredMultas = _multas;
      });
    } else {
      print('Error al cargar las multas. Código de estado: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');
    }
  }

  void _filterMultas(String patente) {
    setState(() {
      _filteredMultas = _multas.where((multa) => multa['bitacora']['vehiculo']['patente'].contains(patente)).toList();
      _currentPage = 0;
    });
  }

  List<dynamic> _getPaginatedMultas() {
    final start = _currentPage * _pageSize;
    final end = start + _pageSize;
    return _filteredMultas.sublist(start, end > _filteredMultas.length ? _filteredMultas.length : end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_selectedIndex == 2) _buildAdminWelcomeCard(),
                  SizedBox(height: 20),
                  _getSelectedPage(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Bitácoras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Mantenedores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_late_outlined),
            label: 'Multas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildBitacoraCard();
      case 1:
        return _buildMantenedoresOptions();
      case 2:
        return Center(child: Text(''));
      case 3:
        return _buildMultasSection();
      case 4:
        return _buildUserInfoSection();
      default:
        return Center(child: Text(''));
    }
  }

   Widget _buildBitacoraCard() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (bitacoras.isEmpty) {
      return Center(child: Text("No se encontraron registros en la bitácora."));
    }

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registros de Bitácora',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _fetchBitacoras,
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por Patente',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _filterBitacoras,
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 10,
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Fecha Entrada')),
                  DataColumn(label: Text('Fecha Salida')),
                  DataColumn(label: Text('Patente')),
                  DataColumn(label: Text('Tipo')),
                ],
                rows: _getCurrentPageItems().map((bitacora) {
                  final vehiculo = bitacora['vehiculo'];
                  final esVisita = vehiculo['visita'] != null;
                  return DataRow(cells: [
                    DataCell(Text(bitacora['id'].toString())),
                    DataCell(Text(bitacora['fechain'] ?? 'N/A')),
                    DataCell(Text(bitacora['fechaout'] ?? 'N/A')),
                    DataCell(Text(vehiculo['patente'])),
                    DataCell(Text(esVisita ? 'VISITA' : 'RESIDENTE')),
                  ]);
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousPage,
                  child: Text('Anterior'),
                ),
                Text(
                  'Página ${currentPage + 1} de ${((filteredBitacoras.length - 1) / itemsPerPage).ceil() + 1}',
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  child: Text('Siguiente'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMantenedoresOptions() {
  return Card(
    margin: EdgeInsets.all(16),
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
            'Mantenedores',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.person, color: Colors.blue.shade700),
            title: Text(
              'Administrar Residentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MantenedorResidenteForm()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.group, color: Colors.blue.shade700),
            title: Text(
              'Administrar Visitas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MantenedorVisitaForm()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.directions_car, color: Colors.blue.shade700),
            title: Text(
              'Administrar Vehículos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MantenedorVehiculoForm()),
              );
            },
          ),
        ],
      ),
    ),
  );
}


  Widget _buildMantenedorButton(
      BuildContext context, String entity, Widget formWidget, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24, color: Colors.white),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.blue.shade700,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => formWidget),
          );
        },
        label: Text(
          'Administrar $entity',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }


  Widget _buildUserInfoSection() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        children: [
          Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    nombreCompleto.toUpperCase(),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      (torre == 0 && departamento == 0)
                          ? 'Administración condominio'
                          : 'Torre $torre, Departamento $departamento',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoCard(Icons.warning, 'Multas', multasUltimoMes),
                      _buildInfoCard(Icons.group, 'Visitas', visitasRegistradas),
                    ],
                  ),
                  SizedBox(height: 30),
                  ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue.shade700),
                    title: Text(
                      'Editar información personal',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditPersonalInfoScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.blue.shade700),
                    title: Text(
                      'Cambiar contraseña',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      ),
                      onPressed: _logout,
                      child: Text(
                        "Cerrar sesión",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo_ta.png',
                    height: 50,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Desarrollado por TechApps',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'www.techapps.com',
                    style: TextStyle(fontSize: 14, color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, int count) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 100,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.blue.shade700),
            SizedBox(height: 10),
            Text(
              '$count',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminWelcomeCard() {
  return Container(
    width: MediaQuery.of(context).size.width * 0.9,
    child: Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Bienvenido, Administrador!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              "Aquí podrás gestionar las visitas y el acceso al centro, además de ver bitácoras y administrar datos.",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 100,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FormVisita1()),
                  );
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Registrar Visita',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildMultasSection() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multas Ultimo Mes',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _patenteController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por Patente',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _filterMultas(value);
                  },
                ),
                SizedBox(height: 16),
                _filteredMultas.isEmpty
                    ? Center(child: Text('No hay multas registradas'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _getPaginatedMultas().length,
                        itemBuilder: (context, index) {
                          final multa = _getPaginatedMultas()[index];
                          final vehiculo = multa['bitacora']['vehiculo'];
                          return ListTile(
                            title: Text('Patente: ${vehiculo['patente']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Deuda Total: ${multa['totalDeuda']} UF'),
                                Text('Fecha de Multa: ${multa['fechaMulta']}'),
                                Text('Marca: ${vehiculo['marca']}, Modelo: ${vehiculo['modelo']}'),
                              ],
                            ),
                          );
                        },
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                    ),
                    Text('Página ${_currentPage + 1}'),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: (_currentPage + 1) * _pageSize < _filteredMultas.length
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildRegistrarVisitaButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Acción para registrar visita
      },
      icon: Icon(Icons.add, color: Colors.white, size: 24),
      label: Text(
        'Registrar Visita',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(20), // Botón cuadrado
        backgroundColor: Colors.blue.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Bordes más cuadrados
        ),
      ),
    );
  }


}
