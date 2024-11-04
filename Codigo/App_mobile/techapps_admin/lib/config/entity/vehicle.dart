
 class Vehicle {
  final String patente;
  final String marca;
  final String modelo;
  final int anio;
  final String primerNombre;
  final String apellidos;
  final String rut;

  Vehicle({
    required this.patente,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.primerNombre,
    required this.apellidos,
    required this.rut,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      patente: json['patente'],
      marca: json['marca'],
      modelo: json['modelo'],
      anio: json['anio'],
      primerNombre: json['primer_nombre'],
      apellidos: json['apellidos'],
      rut: json['rut'],
    );
  }
} 