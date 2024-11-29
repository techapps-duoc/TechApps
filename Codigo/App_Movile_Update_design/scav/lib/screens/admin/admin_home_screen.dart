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
          .where((bitacora) => bitacora['vehiculo']['patente']
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
    // Tamaño fijo para la cantidad de elementos por página
    final int pageSize = 4;

    // Calcula el índice de inicio y fin basado en la página actual
    final start = _currentPage * pageSize;
    final end = start + pageSize;

    // Retorna un subconjunto de la lista, ajustando el límite para evitar errores
    return _filteredMultas.sublist(
      start,
      end > _filteredMultas.length ? _filteredMultas.length : end,
    );
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
      elevation: 8,
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
                const Text(
                  'Registros de Bitácora',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: _fetchBitacoras, // Acción del botón
                  child: Container(
                    width: 40, // Ancho del círculo
                    height: 40, // Altura del círculo
                    decoration: const BoxDecoration(
                      color: Colors.blue, // Color de fondo azul
                      shape: BoxShape.circle, // Forma circular
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white, // Color del icono
                      size: 32, // Tamaño del icono
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Fondo blanco para el buscador
                borderRadius: BorderRadius.circular(12), // Bordes redondeados
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Color de la sombra
                    blurRadius: 10, // Desenfoque de la sombra
                    offset: const Offset(0, 4), // Desplazamiento de la sombra
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar por Patente',
                  labelStyle:
                      TextStyle(color: Colors.grey[600]), // Estilo del texto
                  border: InputBorder.none, // Elimina el borde predeterminado
                  prefixIcon: const Icon(Icons.search,
                      color: Colors.blue), // Ícono de búsqueda
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 5, horizontal: 10), // Espaciado interno
                ),
                onChanged: _filterBitacoras,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.blue.shade100),
                dataRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.white), // Fondo de las filas
                columnSpacing: 20,
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue.shade900,
                ),
                dataTextStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                columns: const [
                  DataColumn(label: Text('Patente')),
                  DataColumn(
                    label: Text(
                      'Fecha\nEntrada',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Hora\nEntrada',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Hora\nSalida',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(label: Text('Tipo')),
                ],
                rows: _getCurrentPageItems().map((bitacora) {
                  final vehiculo = bitacora['vehiculo'];
                  final esVisita = vehiculo['visita'] != null;

                  // Función para formatear fecha (YY-MM-DD)
                  String formatFecha(String? fecha) {
                    if (fecha == null || fecha.isEmpty) return 'N/A';
                    try {
                      final parsedDate = DateTime.parse(fecha);
                      return '${parsedDate.year.toString().substring(2)}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
                    } catch (e) {
                      return 'N/A';
                    }
                  }

                  // Función para extraer hora (HH:MM)
                  String formatHora(String? fecha) {
                    if (fecha == null || fecha.isEmpty) return 'N/A';
                    try {
                      final parsedDate = DateTime.parse(fecha);
                      return '${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
                    } catch (e) {
                      return 'N/A';
                    }
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text(vehiculo['patente'])), // Patente
                      DataCell(Text(
                          formatFecha(bitacora['fechain']))), // Fecha Entrada
                      DataCell(Text(
                          formatHora(bitacora['fechain']))), // Hora Entrada
                      DataCell(Text(
                          formatHora(bitacora['fechaout']))), // Hora Salida

                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 25, // Ancho del círculo
                              height: 25, // Altura del círculo
                              decoration: BoxDecoration(
                                shape: BoxShape.circle, // Forma de círculo
                                color: esVisita
                                    ? Colors.orange
                                    : Colors.green, // Color según el tipo
                              ),
                            ),
                            const SizedBox(
                                width:
                                    8), // Espacio entre el círculo y el texto
                            Text(
                              esVisita ? 'VISITA' : 'RESIDENTE',
                              style: TextStyle(
                                color: esVisita
                                    ? Colors.orange.shade800
                                    : Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Anterior',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Página ${currentPage + 1} de ${((filteredBitacoras.length - 1) / itemsPerPage).ceil() + 1}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Siguiente',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMantenedoresOptions() {
    return Column(
      children: [
        // Logo en la parte superior
        Container(
          margin: const EdgeInsets.only(
              top: 10, bottom: 20), // Espaciado superior e inferior
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26, // Sombra suave
                blurRadius: 60, // Difusión de la sombra
                offset: Offset(0, 8), // Desplazamiento de la sombra
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo2.png',
            height: 200, // Ajusta el tamaño del logo
          ),
        ),
        // Card con las opciones de mantenedores
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade50], // Degradado suave
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mantenedores',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildMantenedorTile(
                    context,
                    icon: Icons.person,
                    label: 'Administrar Residentes',
                    color: Colors.blue.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MantenedorResidenteForm()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMantenedorTile(
                    context,
                    icon: Icons.group,
                    label: 'Administrar Visitas',
                    color: Colors.blue.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MantenedorVisitaForm()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMantenedorTile(
                    context,
                    icon: Icons.directions_car,
                    label: 'Administrar Vehículos',
                    color: Colors.blue.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MantenedorVehiculoForm()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMantenedorTile(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), // Fondo azul claro
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color, // Ícono azul
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          // Card Principal
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
                  // Título
                  Text(
                    'ADMINISTRACIÓN CONDOMINIO',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  // Información adicional
                  Text(
                    'Administración condominio',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botones de estadísticas (Multas y Visitas)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoCard(Icons.warning, 'Multas', multasUltimoMes),
                      _buildInfoCard(
                          Icons.group, 'Visitas', visitasRegistradas),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Opciones
                  _buildOptionTile(Icons.edit, 'Editar información personal',
                      Colors.blue.shade700, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditPersonalInfoScreen()),
                    );
                  }),
                  _buildOptionTile(
                      Icons.lock, 'Cambiar contraseña', Colors.blue.shade700,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangePasswordScreen()),
                    );
                  }),
                  const SizedBox(height: 20),
                  // Botón de Cerrar Sesión
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Color del botón
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Bordes redondeados
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 30),
                      elevation: 10, // Altura de la sombra
                      shadowColor: Colors.black.withOpacity(
                          0.9), // Color y transparencia de la sombra
                    ),
                    onPressed: _logout, // Acción del botón
                    child: const Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Color del texto
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Card Secundario
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
                        color: Colors.white, // Sombra blanca
                        blurRadius: 65, // Difuminado
                        spreadRadius: 5, // Expansión de la sombra
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo_ta.png',
                    height: 90, // Tamaño del logo
                  ),
                ),
                const SizedBox(height: 15),
                // Texto principal
                const Text(
                  'Desarrollado por TechApps',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Texto en blanco
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                // Enlace
                const Text(
                  'www.techapps.com',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue, // Texto en blanco
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

// Tarjetas de Multas y Visitas con Estilo Circular
  Widget _buildInfoCard(IconData icon, String label, int count) {
    return Container(
      width: 100,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade50,
            child: Icon(
              icon,
              size: 30,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

// Opciones con Iconos y Texto
  Widget _buildOptionTile(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  Widget _buildAdminWelcomeCard() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título
                Text(
                  "¡Bienvenido, Administrador!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                // Descripción
                Text(
                  "Aquí puedes gestionar las visitas, el acceso al centro, y administrar bitácoras de manera eficiente.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5, // Espaciado entre líneas
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                // Botón
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FormVisita1()),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Registrar Visita',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.blue.shade200,
                      elevation: 6,
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

  Widget _buildMultasSection() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        child: Column(
          children: [
            // Título principal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Multas Último Mes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            // Buscador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _patenteController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por Patente',
                    prefixIcon: Icon(Icons.search, color: Colors.blue),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                  ),
                  onChanged: (value) {
                    _filterMultas(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Lista de multas paginada
            _filteredMultas.isEmpty
                ? const Center(child: Text('No hay multas registradas'))
                : Column(
                    children: _getPaginatedMultas().map((multa) {
                      final vehiculo = multa['bitacora']['vehiculo'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Patente
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Patente: ${vehiculo['patente']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    Icon(
                                      Icons.directions_car,
                                      color: Colors.blue.shade300,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Detalles de multa
                                Text(
                                  'Deuda Total: ${multa['totalDeuda']} UF',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fecha de Multa: ${multa['fechaMulta'].split('T')[0]}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Marca: ${vehiculo['marca']}, Modelo: ${vehiculo['modelo']}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 20),
            // Paginación
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
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Anterior',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'Página ${_currentPage + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: (_currentPage + 1) * 4 < _filteredMultas.length
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Siguiente',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
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
