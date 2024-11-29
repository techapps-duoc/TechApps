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
        print(
            "Payload del token: $payload"); // Imprime el contenido del payload

        setState(() {
          nombreCompleto =
              '${payload['nombre'] ?? 'Sin Nombre'} ${payload['apellido'] ?? 'Sin Apellido'}';
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
      Uri.parse(
          '${AppConfig.apiUrl}:30050/api/v1/multas/residente/$residenteId'),
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
      print(
          'Error al cargar las multas. Código de estado: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');
    }
  }

  void _filterMultas(String patente) {
    setState(() {
      _filteredMultas = _multas
          .where((multa) =>
              multa['bitacora']['vehiculo']['patente'].contains(patente))
          .toList();
      _currentPage = 0;
    });
  }

  List<dynamic> _getPaginatedMultas() {
    final start = _currentPage * _pageSize;
    final end = start + _pageSize;
    return _filteredMultas.sublist(
        start, end > _filteredMultas.length ? _filteredMultas.length : end);
  }

  Future<List<dynamic>> _fetchHistorialVisitas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    String? residenteId = await _getResidenteIdFromToken();

    if (token == null || residenteId == null) return [];

    final response = await http.get(
      Uri.parse(
          '${AppConfig.apiUrl}:30030/api/v1/visita/residente/$residenteId/visitas'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type':
            'application/json; charset=UTF-8', // Asegura UTF-8 en el encabezado
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
      Uri.parse(
          '${AppConfig.apiUrl}:30030/api/v1/visita/autorizaciones/pendientes/residente/$residenteId'),
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
    final url =
        '${AppConfig.apiUrl}:30030/api/v1/visita/autorizacion/estado/$autorizacionId?estado=$estado';
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
        print(
            "Error al actualizar el estado de la visita: ${response.statusCode}");
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
          // Card Principal - Información del usuario
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
                  // Nombre del usuario estilizado
                  Text(
                    nombreCompleto.toUpperCase(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Información adicional (Torre y Departamento)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      torre == 0
                          ? 'Casa $departamento'
                          : 'Torre $torre, Departamento $departamento',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botones de estadísticas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoCard(Icons.warning, 'Multas', multasUltimoMes),
                      _buildInfoCard(
                          Icons.group, 'Visitas', visitasRegistradas),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Opciones adicionales (Editar información y Cambiar contraseña)
                  _buildOptionTile(
                    Icons.edit,
                    'Editar información personal',
                    Colors.blue.shade700,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPersonalInfoScreen(),
                        ),
                      );
                    },
                  ),
                  _buildOptionTile(
                    Icons.lock,
                    'Cambiar contraseña',
                    Colors.blue.shade700,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Botón de cerrar sesión estilizado
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    onPressed: _logout,
                    child: const Text(
                      "Cerrar sesión",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Card Secundario - Información del desarrollador
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo con sombra blanca
                Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 65,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo_ta.png', // Ruta del logo
                    height: 90,
                  ),
                ),
                const SizedBox(height: 15),

                // Texto principal
                const Text(
                  'Desarrollado por TechApps',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),

                // Enlace
                const Text(
                  'www.techapps.com',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
      IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildMultasSection() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título estilizado
                Center(
                  child: Text(
                    'Multas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo de búsqueda estilizado
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _patenteController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por Patente',
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                    ),
                    onChanged: (value) {
                      _filterMultas(value);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Listado de multas
                _filteredMultas.isEmpty
                    ? Center(
                        child: Text(
                          'No hay multas registradas',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : SizedBox(
                        height: 300, // Altura fija para el listado
                        child: ListView.builder(
                          itemCount: _getPaginatedMultas().length,
                          itemBuilder: (context, index) {
                            final multa = _getPaginatedMultas()[index];
                            final vehiculo = multa['bitacora']['vehiculo'];

                            return Card(
                              color: Colors
                                  .white, // Fondo blanco para las tarjetas
                              margin: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Patente: ${vehiculo['patente']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Deuda Total: ${multa['totalDeuda']} UF',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Fecha de Multa: ${multa['fechaMulta'].split('T')[0]}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Marca: ${vehiculo['marca']}, Modelo: ${vehiculo['modelo']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 170, 10, 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                const SizedBox(height: 10),

                // Botones de paginación estilizados
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage > 0
                            ? Colors.blue.shade700
                            : Colors.grey[300], // Azul si está habilitado
                        disabledBackgroundColor:
                            Colors.grey[300], // Gris si está deshabilitado
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white), // Flecha blanca
                    ),
                    Text(
                      'Página ${_currentPage + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: (_currentPage + 1) * _pageSize <
                              _filteredMultas.length
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_currentPage + 1) * _pageSize <
                                _filteredMultas.length
                            ? Colors.blue.shade700
                            : Colors.grey[300], // Azul si está habilitado
                        disabledBackgroundColor:
                            Colors.grey[300], // Gris si está deshabilitado
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.arrow_forward,
                          color: Colors.white), // Flecha blanca
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
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título principal estilizado
                Text(
                  "Registro Previo",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                // Descripción con fuente estilizada
                Text(
                  "Esta sección te permite registrar una visita de forma anticipada, para que no requiera confirmación al llegar.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // Campo de texto estilizado
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _rutController,
                    decoration: InputDecoration(
                      hintText: 'Ingrese RUT de la visita',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon:
                          Icon(Icons.badge, color: Colors.blue.shade700),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Botón estilizado
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterVisitScreen(
                            rut: _rutController.text.trim()),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add,
                      size: 24, color: Colors.white),
                  label: const Text(
                    "Registrar Visita",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700, // Corregido
                    foregroundColor: Colors.white, // Para texto e iconos
                    shadowColor: Colors.blueAccent,
                    elevation: 5,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error al cargar visitas pendientes',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No tienes visitas pendientes',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true, // Ajustar dentro del ScrollView
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final visita = snapshot.data![index];
              final autorizacionId = visita['id'];
              final visitaInfo = visita['registroVisita']['visita'];
              final fechaVisita = visita['registroVisita']['fechaVisita'];

              // Formatear fecha y hora
              String formatFechaHora(String fechaHora) {
                try {
                  final parsedDate = DateTime.parse(fechaHora);
                  final fecha =
                      'Fecha: ${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
                  final hora =
                      'Hora: ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}:${parsedDate.second.toString().padLeft(2, '0')}';
                  return '$fecha\n$hora';
                } catch (e) {
                  return 'Fecha no válida';
                }
              }

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.blue.shade700,
                            size: 40,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${visitaInfo['nombre']} ${visitaInfo['apellido']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'RUT: ${visitaInfo['rut']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                formatFechaHora(fechaVisita),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _approveVisit(autorizacionId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _rejectVisit(autorizacionId),
                          ),
                        ],
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
            height: MediaQuery.of(context).size.height *
                0.8, // Ajusta la altura según sea necesario
            child: Column(
              children: [
                // Título estilizado
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Historial de Visitas',
                    style: TextStyle(
                      fontSize: 28, // Tamaño de fuente más grande
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Color azul similar al diseño
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _fetchHistorialVisitas(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Error al cargar el historial de visitas',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No hay visitas registradas',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final visita = snapshot.data![index];
                            final fechaHora =
                                visita['fechaVisita']?.toString() ?? 'N/A';
                            final fecha =
                                fechaHora.split("T").first; // Extrae la fecha
                            final hora = fechaHora.split("T").length > 1
                                ? fechaHora.split("T")[1].split(".").first
                                : 'N/A'; // Extrae la hora

                            return Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.blue.shade700,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${visita['visita']['nombre']} ${visita['visita']['apellido']}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Fecha: $fecha',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              'Hora: $hora',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'ID: ${visita['visita']['id']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.blue.shade700),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
