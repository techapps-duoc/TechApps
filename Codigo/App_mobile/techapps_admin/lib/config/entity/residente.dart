

//---modelado.-----------------------
class Residente {
  final int id;
  final String rut;
  final String nombre;
  final String apellido;
  final String correo;
  //final int torre;
  int torre;
  final int departamento;

  Residente({
    required this.id,
    required this.rut,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.torre,
    required this.departamento,
  });


 //manejo de json residente
  factory Residente.fromJson(Map<String, dynamic> json) {
    return Residente(
      id: json['id'],
      rut: json['rut'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      correo: json['correo'],
      torre: json['torre'],
      departamento: json['departamento'],
    );
  }
}