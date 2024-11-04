import 'package:flutter/material.dart';
import 'package:techapps_admin/widgets/background_general.dart';
import 'package:techapps_admin/config/entity/residente.dart';
import 'package:techapps_admin/widgets/card_container_form.dart';
//import 'package:techapps_admin/widgets/widgets.dart';
import 'package:techapps_admin/ui/input_decorations.dart';
import 'package:go_router/go_router.dart';
//nuevas importaciones
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:techapps_admin/config/entity/vehicle.dart';
//import 'vehicle_model.dart';
import 'package:techapps_admin/config/entity/residente.dart';
import 'package:techapps_admin/config/services/AuthService.dart';


import 'package:flutter/material.dart';


//-------------metodo buscar vehiculo por patente API EXTERNA--------------

class ApiService {

final AuthService authService = AuthService();

Future<Vehicle?> buscarVehiculo(String patente) async {
    final String apiUrl = 'http://localhost:8082/api/v1/vehiculo-visita/patente/$patente';

    try {
      final token = await authService.getToken();
      if (token == null) {
        print('Error: Token no encontrado');
        return null;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Incluye el token en el encabezado
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 200) {
          print('codigo respuesta : ${response.statusCode}');
          return Vehicle.fromJson(jsonResponse['data']);
      
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception('Error al cargar el vehículo');
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
    
  }

/*
  Future<Vehicle?>BuscarVehiculo(String patente) async {
    final String apiUrl = 'http://localhost:8082/api/v1/vehiculo-visita/patente/$patente';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 200) {
          return Vehicle.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception('Error al cargar el vehículo');
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

Future<void> sendRequestWithToken() async {
    final token = await AuthService().getToken();
    //final token = await getToken();
    if (token == null) {
      print('Error: Token no encontrado');
      return;
    }

    final url = Uri.parse('http://localhost:8083/api/secure-endpoint');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Agrega el token en el encabezado
      },
    );

    print('Estado de la respuesta: ${response.statusCode}');
    print('Cuerpo de la respuesta: ${response.body}');
  }*/



}



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VehiculoScreen(),
    );
  }
}

class VehiculoScreen extends StatefulWidget {
  @override
  _VehicleScreenState createState() => _VehicleScreenState();
}


// Clases de estilo y decoraciones como _HeaderIconVehiculo e InputDecorations
class _HeaderIconVehiculo extends StatelessWidget {
  const _HeaderIconVehiculo();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
        child:Image.asset('assets/coche.png', width:150.0, height: 140.0) 
        //const Icon(Icons.car_repair_sharp, color: Colors.white, size: 130),
      ),
    );
  }
}

class InputDecorations {
  static InputDecoration authInputDecoration({
    required String hintText,
    required String labelText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: Icon(prefixIcon, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class CardContainerForm extends StatelessWidget {
  final Widget child;
  const CardContainerForm({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5)),
        ],
      ),
      child: this.child,
    );
  }
}

/*
  Widget _mostrarDatosResidente(Residente residente) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
  
      TextFormField(
        initialValue: '${residente.nombre} ${residente.apellido}',
        decoration: InputDecorations.authInputDecoration(
          hintText: '',
          labelText: 'Nombre Residente',
          prefixIcon: Icons.person,
        ),
        readOnly: true,
        style: TextStyle(fontSize: 20),
      ),
      const SizedBox(height: 10),
      TextFormField(
        initialValue: '${residente.torre}',
        decoration: InputDecorations.authInputDecoration(
          hintText: '',
          labelText: 'Torre Residencia',
          prefixIcon: Icons.location_city,
        ),
        readOnly: true,
        style: TextStyle(fontSize: 20),
      ),
      const SizedBox(height: 10),
      TextFormField(
        initialValue: '${residente.departamento}',
        decoration: InputDecorations.authInputDecoration(
          hintText: '',
          labelText: 'Num. Departamento',
          prefixIcon: Icons.apartment,
        ),
        readOnly: true,
        style: TextStyle(fontSize: 20),
      ),
    ],
  );
}*/


//----prueba-------------------

class _VehicleScreenState extends State<VehiculoScreen> {
  final ApiService apiService = ApiService();
  Vehicle? vehicle;

  // Variables para tipo de residencia
  Residente? _residente;
  String tipoResidencia = 'departamento';

  // Controladores de los campos
  final patenteController = TextEditingController();
  final marcaController = TextEditingController();
  final modeloController = TextEditingController();
  final anioController = TextEditingController();
  final primerNombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final rutController = TextEditingController();
  final torreController = TextEditingController();
  final numeroController = TextEditingController();
  final residenteController= TextEditingController();

  @override
  void dispose() {
    patenteController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    anioController.dispose();
    primerNombreController.dispose();
    apellidosController.dispose();
    rutController.dispose();
    torreController.dispose();
    numeroController.dispose();
    residenteController.dispose();
    patenteController.removeListener(fetchVehicleData);
    super.dispose();
  }

    void fetchVehicleData() async {
    final String patente = patenteController.text;
    final fetchedVehicle = await apiService.buscarVehiculo(patente);
    if (fetchedVehicle != null) {
      setState(() {
        vehicle = fetchedVehicle;
        marcaController.text = vehicle!.marca;
        modeloController.text = vehicle!.modelo;
        anioController.text = vehicle!.anio.toString();
        primerNombreController.text = vehicle!.primerNombre;
        apellidosController.text = vehicle!.apellidos;
        rutController.text = vehicle!.rut;
      });
    }
  }

//metodos agregados para llamar automaticamente al metodo de traer datos por patente

/*@override
void initState() {
  super.initState();
  patenteController.addListener(() {
    // Llama al método cuando hay un cambio en el campo de la patente
    if (patenteController.text.isNotEmpty) {
      fetchVehicleData();
    }
  });
}*/

/*@override
void dispose() {
  patenteController.removeListener(fetchVehicleData); // Remueve el listener
  patenteController.dispose();
  super.dispose();
}*/

// fin metodo traer datos por patente


@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGeneral(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _HeaderIconVehiculo(),
              const SizedBox(height: 10),
              CardContainerForm(
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Text('Información de Residente', style: TextStyle(fontSize: 25)),
                    const SizedBox(height: 10),

                    // Radio para seleccionar Casa o Departamento
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: 'casa',
                          groupValue: tipoResidencia,
                          onChanged: (value) {
                            setState(() {
                              tipoResidencia = value!;
                              if (tipoResidencia == 'casa') {
                                torreController.text = '0';
                              } else {
                                torreController.clear();
                              }
                            });
                          },
                        ),
                        const Text('Casa'),
                        Radio<String>(
                          value: 'departamento',
                          groupValue: tipoResidencia,
                          onChanged: (value) {
                            setState(() {
                              tipoResidencia = value!;
                              torreController.clear();
                            });
                          },
                        ),
                        const Text('Departamento'),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Row para los campos de Torre y Número
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: torreController,
                            enabled: tipoResidencia == 'departamento',
                            decoration: InputDecorations.authInputDecoration(
                              hintText: '',
                              labelText: 'Torre',
                              prefixIcon: Icons.apartment,
                            ),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: numeroController,
                            decoration: InputDecorations.authInputDecoration(
                              hintText: '',
                              labelText: 'Número Domicilio',
                              prefixIcon: Icons.format_list_numbered,
                            ),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    
                    Text('Información de Visitante', style: TextStyle(fontSize: 25)),
                    const SizedBox(height: 10),

                    // Row para los campos RUT y Primer Nombre
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: rutController,
                            decoration: InputDecorations.authInputDecoration(
                              hintText: '',
                              labelText: 'RUT',
                              prefixIcon: Icons.card_membership,
                            ),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: primerNombreController,
                            decoration: InputDecorations.authInputDecoration(
                              hintText: '',
                              labelText: 'Primer Nombre',
                              prefixIcon: Icons.person,
                            ),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: apellidosController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Apellidos',
                        prefixIcon: Icons.family_restroom,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),

                    const SizedBox(height: 10),

                    // Botón Guardar Visita que ocupa todo el ancho
                /*    MaterialButton(
                      minWidth: double.infinity,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Colors.green,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: const Text('Guardar Visita', style: TextStyle(color: Colors.white)),
                      ),
                      onPressed: () {},
                    ),*/

                    const SizedBox(height: 10),

                    // TextFormField de Patente que ejecuta fetchVehicleData al ingresar
                    /*TextFormField(
                      controller: patenteController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Patente',
                        prefixIcon: Icons.directions_car,
                      ),
                      style: TextStyle(fontSize: 20),
                      onEditingComplete: fetchVehicleData,
                    ),*/

                    TextFormField(
                    controller: patenteController,
                    decoration: InputDecorations.authInputDecoration(
                      hintText: '',
                      labelText: 'Patente',
                      prefixIcon: Icons.directions_car,
                    ),
                    style: TextStyle(fontSize: 20),
                  ),

                    
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: marcaController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Marca',
                        prefixIcon: Icons.auto_mode_outlined,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: modeloController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Modelo',
                        prefixIcon: Icons.model_training,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    
                    // Botón Guardar Vehículo que ocupa todo el ancho
                    /*MaterialButton(
                      minWidth: double.infinity,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Colors.green,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: const Text('Guardar Vehículo', style: TextStyle(color: Colors.white)),
                      ),
                      onPressed: fetchVehicleData,
                    ),*/
                      Row(
                      children: [
                        Expanded(
                          child: MaterialButton(
                      minWidth: double.infinity,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Colors.green,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: const Text('Obtener Vehículo', style: TextStyle(color: Colors.white)),
                      ),
                      onPressed: fetchVehicleData,
                    ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MaterialButton(
                      minWidth: double.infinity,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Colors.green,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: const Text('Guardar Vehiculo', style: TextStyle(color: Colors.white)),
                      ),
                      onPressed: (){},
                    )
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }




// funcional
/*
 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: BackgroundGeneral(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const _HeaderIconVehiculo(),
            const SizedBox(height: 10),
            CardContainerForm(
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Text('Información de Residente', style: TextStyle(fontSize: 25)),
                  const SizedBox(height: 10),

                  // Radio para seleccionar Casa o Departamento
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: 'casa',
                        groupValue: tipoResidencia,
                        onChanged: (value) {
                          setState(() {
                            tipoResidencia = value!;
                            if (tipoResidencia == 'casa') {
                              torreController.text = '0';
                            } else {
                              torreController.clear();
                            }
                          });
                        },
                      ),
                      const Text('Casa'),
                      Radio<String>(
                        value: 'departamento',
                        groupValue: tipoResidencia,
                        onChanged: (value) {
                          setState(() {
                            tipoResidencia = value!;
                            torreController.clear();
                          });
                        },
                      ),
                      const Text('Departamento'),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Row para los campos de Torre y Número
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: torreController,
                          enabled: tipoResidencia == 'departamento',
                          decoration: InputDecorations.authInputDecoration(
                            hintText: '',
                            labelText: 'Torre',
                            prefixIcon: Icons.apartment,
                          ),
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: numeroController,
                          decoration: InputDecorations.authInputDecoration(
                            hintText: '',
                            labelText: 'Número Domicilio',
                            prefixIcon: Icons.format_list_numbered,
                          ),
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  
                  Text('Información de Visitante', style: TextStyle(fontSize: 25)),
                  const SizedBox(height: 10),

                  // Row para los campos RUT y Primer Nombre
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: rutController,
                          decoration: InputDecorations.authInputDecoration(
                            hintText: '',
                            labelText: 'RUT',
                            prefixIcon: Icons.card_membership,
                          ),
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: primerNombreController,
                          decoration: InputDecorations.authInputDecoration(
                            hintText: '',
                            labelText: 'Primer Nombre',
                            prefixIcon: Icons.person,
                          ),
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: apellidosController,
                    decoration: InputDecorations.authInputDecoration(
                      hintText: '',
                      labelText: 'Apellidos',
                      prefixIcon: Icons.family_restroom,
                    ),
                    style: TextStyle(fontSize: 20),
                  ),

                  const SizedBox(height: 10),

                  // Botón Guardar Visita alineado a la izquierda
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      MaterialButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: Colors.green,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          child: const Text('Guardar Visita', style: TextStyle(color: Colors.white)),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // TextFormField de Patente
                  TextFormField(
                    controller: patenteController,
                    decoration: InputDecorations.authInputDecoration(
                      hintText: '',
                      labelText: 'Patente',
                      prefixIcon: Icons.directions_car,
                    ),
                    style: TextStyle(fontSize: 20),
                  ),
                  
                  const SizedBox(height: 10),

                  // Otros TextFormFields con sus iconos correspondientes
                  TextFormField(
                    controller: marcaController,
                    decoration: InputDecorations.authInputDecoration(
                      hintText: '',
                      labelText: 'Marca',
                      prefixIcon: Icons.auto_mode_outlined,
                    ),
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: modeloController,
                    decoration: InputDecorations.authInputDecoration(
                      hintText: '',
                      labelText: 'Modelo',
                      prefixIcon: Icons.model_training,
                    ),
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  
                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: Colors.green,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: const Text('Guardar Vehiculo', style: TextStyle(color: Colors.white)),
                        ),
                        onPressed: fetchVehicleData,
                      ),
                      const SizedBox(width: 20),
                     /* MaterialButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: Colors.blueAccent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                        ),
                        onPressed: () {
                          // Acción al presionar "Aceptar"
                        },
                      ),*/
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
} */

//funcional anterior
  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGeneral(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _HeaderIconVehiculo(),
              const SizedBox(height: 5),
              CardContainerForm(
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Text('Información de Residente', style: TextStyle(fontSize: 25)),
                    const SizedBox(height: 5),
                    
                    // Radio para seleccionar Casa o Departamento
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: 'casa',
                          groupValue: tipoResidencia,
                          onChanged: (value) {
                            setState(() {
                              tipoResidencia = value!;
                              if (tipoResidencia == 'casa') {
                                torreController.text = '0';
                              } else {
                                torreController.clear();
                              }
                            });
                          },
                        ),
                        const Text('Casa'),
                        Radio<String>(
                          value: 'departamento',
                          groupValue: tipoResidencia,
                          onChanged: (value) {
                            setState(() {
                              tipoResidencia = value!;
                              torreController.clear();
                            });
                          },
                        ),
                        const Text('Departamento'),
                      ],
                    ),
                    const SizedBox(height: 10),

                    //Datos de residente
                    // TextFormField de Torre
                    TextFormField(
                      controller: torreController,
                      enabled: tipoResidencia == 'departamento',
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Torre',
                        prefixIcon: Icons.apartment,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),

                    // TextFormField de Numero (siempre habilitado)
                    TextFormField(
                      controller: numeroController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Número',
                        prefixIcon: Icons.format_list_numbered,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    
                  Text('Información de Visitante', style: TextStyle(fontSize: 25)),
                    const SizedBox(height: 10),
                  TextFormField(
                      controller: rutController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'RUT',
                        prefixIcon: Icons.card_membership,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                  const SizedBox(height: 10),

                  TextFormField(
                      controller: primerNombreController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Primer Nombre',
                        prefixIcon: Icons.person,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: apellidosController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Apellidos',
                        prefixIcon: Icons.family_restroom,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),

                  //datos de vehiculo
                    TextFormField(
                      controller: patenteController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Patente',
                        prefixIcon: Icons.numbers,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
        
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: marcaController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Marca',
                        prefixIcon: Icons.auto_mode_outlined,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: modeloController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Modelo',
                        prefixIcon: Icons.model_training,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                  
                    const SizedBox(height: 20),



                    // Botones de acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          color: Colors.green,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: const Text('Consultar', style: TextStyle(color: Colors.white)),
                          ),
                          onPressed: fetchVehicleData,
                        ),
                        const SizedBox(width: 20),
                        MaterialButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          color: Colors.blueAccent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                          ),
                          onPressed: () {
                            // Acción al presionar "Aceptar"
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }*/
}








//--------funcional

/*
class _VehicleScreenState extends State<VehiculoScreen> {
  final ApiService apiService = ApiService();
  Vehicle? vehicle;

  // Controladores y variables para los campos del residente
 //final TextEditingController _rutController = TextEditingController();
  Residente? _residente;
  String? _mensajeError;
  String tipoResidencia = 'departamento'; // Inicialización con 'departamento'


  // Controladores para los campos editables de vehículo
  final patenteController = TextEditingController();
  final marcaController = TextEditingController();
  final modeloController = TextEditingController();
  final anioController = TextEditingController();
  final primerNombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final rutController = TextEditingController();

  @override
  void dispose() {
    patenteController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    anioController.dispose();
    primerNombreController.dispose();
    apellidosController.dispose();
    rutController.dispose();
    super.dispose();
  }

  void fetchVehicleData() async {
    final String patente = patenteController.text;
    final fetchedVehicle = await apiService.BuscarVehiculo(patente);
    if (fetchedVehicle != null) {
      setState(() {
        vehicle = fetchedVehicle;
        marcaController.text = vehicle!.marca;
        modeloController.text = vehicle!.modelo;
        anioController.text = vehicle!.anio.toString();
        primerNombreController.text = vehicle!.primerNombre;
        apellidosController.text = vehicle!.apellidos;
        rutController.text = vehicle!.rut;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGeneral(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _HeaderIconVehiculo(),
              const SizedBox(height: 10),
              CardContainerForm(
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    // Información del residente
                    Text(
                      'Información de Residente',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    
                    // Radio para seleccionar Casa o Departamento
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: 'casa',
                          groupValue: tipoResidencia,
                          onChanged: (value) {
                            setState(() {
                              tipoResidencia = value!;
                              if (tipoResidencia == 'casa') {
                                _residente?.torre= 0;
                              }
                            });
                          },
                        ),
                        const Text('Casa'),
                        Radio<String>(
                          value: 'departamento',
                          groupValue: tipoResidencia,
                          onChanged: (value) {
                            setState(() {
                              tipoResidencia = value!;
                            });
                          },
                        ),
                        const Text('Departamento'),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      //controller: patenteController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Torre',
                        prefixIcon: Icons.numbers,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                      TextFormField(
                      //controller: patenteController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Numero',
                        prefixIcon: Icons.numbers,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),

                      TextFormField(
                     // controller: patenteController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Nombre Residente',
                        prefixIcon: Icons.numbers,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),

                    const SizedBox(height: 20),

                    // Campos de Vehículo
                    TextFormField(
                      controller: patenteController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Patente',
                        prefixIcon: Icons.numbers,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: marcaController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Marca',
                        prefixIcon: Icons.auto_mode_outlined,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: modeloController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Modelo',
                        prefixIcon: Icons.model_training,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: primerNombreController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Primer Nombre',
                        prefixIcon: Icons.person,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: apellidosController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'Apellidos',
                        prefixIcon: Icons.family_restroom,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: rutController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: '',
                        labelText: 'RUT',
                        prefixIcon: Icons.card_membership,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          color: Colors.green,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: const Text('Consultar', style: TextStyle(color: Colors.white)),
                          ),
                          onPressed: fetchVehicleData,
                        
                        ),
                        const SizedBox(width: 20),
                        MaterialButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          color: Colors.blueAccent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                          ),
                          onPressed: () {
                            // Acción al presionar "Aceptar"
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
