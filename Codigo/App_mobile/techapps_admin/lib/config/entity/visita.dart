
import 'package:techapps_admin/config/entity/residente.dart';


class Visita {
  final int id;
  final String rut;
  final String nombre;
  final String apellido;
  final Residente residente;

  Visita({
    required this.id,
    required this.rut,
    required this.nombre,
    required this.apellido,
    required this.residente,
  });
}