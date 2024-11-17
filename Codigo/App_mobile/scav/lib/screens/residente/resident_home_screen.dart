import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:scav/screens/residente/change_password_screen.dart';
import 'package:scav/screens/residente/edit_personal_info.dart';
import 'package:scav/screens/residente/register_visit_screen.dart'; // Importa tu nueva pantalla
import '../../config/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ResidentHomeScreen extends StatefulWidget {
  @override
  _ResidentHomeScreenState createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  int _selectedIndex = 2;
  String nombreCompleto = '';
  int torre = 0;
  int departamento = 0;
  int multasUltimoMes = 0;
  int visitasRegistradas = 0;
  List<dynamic> _multas = [];
  List<dynamic> _filteredMultas = [];
  TextEditingController _patenteController = TextEditingController();
  int _currentPage = 0;
  final int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    _getUserDataFromToken();
  }

 Future<void> _getUserDataFromToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('authToken');

  if (token != null) {
    try {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      print("Payload del token: $payload"); // Imprime el contenido del payload

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

  Future<void> _fetchMultas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    String? residenteId = await _getResidenteIdFromToken();

    if (token == null || residenteId == null) {
      print("Token o Residente ID no encontrados.");
      return;
    }

    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}:30050/api/v1/multas/residente/$residenteId'),
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


  Future<List<dynamic>> _fetchHistorialVisitas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    String? residenteId = await _getResidenteIdFromToken();

    if (token == null || residenteId == null) return [];

    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}:30030/api/v1/visita/residente/$residenteId/visitas'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8', // Asegura UTF-8 en el encabezado
      },
    );

    if (response.statusCode == 200) {
      // Decodifica el contenido de la respuesta como UTF-8
      final decodedBody = utf8.decode(response.bodyBytes);
      return json.decode(decodedBody);
    } else {
      throw Exception('Error al cargar el historial de visitas');
    }
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

  Future<List<dynamic>> _fetchVisitasPendientes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    String? residenteId = await _getResidenteIdFromToken();

    if (token == null || residenteId == null) return [];

    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}:30030/api/v1/visita/autorizaciones/pendientes/residente/$residenteId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return json.decode(decodedBody);
    } else {
      throw Exception('Error al cargar las visitas pendientes');
    }
  }

  Future<void> _updateVisitStatus(int autorizacionId, String estado) async {
    final url = '${AppConfig.apiUrl}:30030/api/v1/visita/autorizacion/estado/$autorizacionId?estado=$estado';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      print("Token no encontrado");
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print("Visita $estado exitosamente");
        // Refresca la lista de visitas pendientes para reflejar los cambios en la interfaz
        setState(() {
          _fetchVisitasPendientes(); // Llama para refrescar la lista si es necesario
        });
      } else {
        print("Error al actualizar el estado de la visita: ${response.statusCode}");
      }
    } catch (e) {
      print("Error en la solicitud de cambio de estado: $e");
    }
  }

  // Método para aprobar la visita
  void _approveVisit(int autorizacionId) {
    _updateVisitStatus(autorizacionId, 'Aprobada');
  }

  // Método para rechazar la visita
  void _rejectVisit(int autorizacionId) {
    _updateVisitStatus(autorizacionId, 'Rechazada');
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

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    Navigator.pushReplacementNamed(context, '/');
  }
  

//WIDGETS

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
                if (_selectedIndex == 2)
                  Container(
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
                              "Bienvenido, $nombreCompleto!",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Tus visitas pendientes de aprobación",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            // Aquí se integra la lista de visitas pendientes
                            _buildPendingVisits(),
                          ],
                        ),
                      ),
                    ),
                  ),
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
          label: 'Historial',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.warning),
          label: 'Multas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add),
          label: 'Registrar Visitas',
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
        return _buildHistorialVisitas();
      case 1:
        return _buildMultasSection();
      case 2:
        return Center(child: Text(''));
      case 3:
        return _buildRegisterVisitCard();
      case 4:
        return _buildUserInfoSection();
      default:
        return Center(child: Text(''));
    }
  }

  Widget _buildUserInfoSection() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        children: [
          // Tarjeta de usuario
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
                      torre == 0
                          ? 'Casa $departamento'
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
          // Tarjeta de información del desarrollador fuera de la tarjeta principal
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
                    'assets/images/logo_ta.png', // Asegúrate de tener esta imagen en tu proyecto
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
                  'Multas',
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

// Tarjeta de "Registro Previo"
Widget _buildRegisterVisitCard() {
  final TextEditingController _rutController = TextEditingController();

  return Center(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Registro Previo",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Esta sección te permite registrar una visita de forma anticipada, para que no requiera confirmación al llegar.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _rutController,
                decoration: InputDecoration(
                  labelText: 'Ingrese RUT de la visita',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterVisitScreen(rut: _rutController.text.trim()),
                    ),
                  );
                },
                icon: Icon(Icons.person_add, size: 24),
                label: Text("Registrar Visita"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(120, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}



  Widget _buildPendingVisits() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchVisitasPendientes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al cargar visitas pendientes'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No tienes visitas pendientes'));
        } else {
          return ListView.builder(
            shrinkWrap: true, // Para que se ajuste dentro del ScrollView
            physics: NeverScrollableScrollPhysics(), // Desactiva desplazamiento propio
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final visita = snapshot.data![index];
              final autorizacionId = visita['id']; // ID de autorización
              final visitaInfo = visita['registroVisita']['visita'];
              final fechaVisita = visita['registroVisita']['fechaVisita'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text('${visitaInfo['nombre']} ${visitaInfo['apellido']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RUT: ${visitaInfo['rut']}'),
                      Text('Fecha de visita: $fechaVisita'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approveVisit(autorizacionId),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectVisit(autorizacionId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }




  Widget _buildHistorialVisitas() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8, // Ajusta la altura según sea necesario
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Centra el contenido en la tarjeta
                  children: [
                    // Título centrado y de mayor tamaño dentro de la tarjeta
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Historial de Visitas',
                        style: TextStyle(
                          fontSize: 28, // Tamaño de fuente más grande
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center, // Centrado
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<dynamic>>(
                        future: _fetchHistorialVisitas(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error al cargar el historial de visitas'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('No hay visitas registradas'));
                          } else {
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final visita = snapshot.data![index];
                                return ListTile(
                                  title: Text('${visita['visita']['nombre']} ${visita['visita']['apellido']}'),
                                  subtitle: Text('Fecha de visita: ${visita['fechaVisita']}'),
                                  trailing: Text('ID: ${visita['visita']['id']}'),
                                  leading: Icon(Icons.person, color: Colors.blue.shade700),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
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
}
