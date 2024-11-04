import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



//Clase de autentificacion JWT
class AuthService {

  final storage = FlutterSecureStorage();

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('http://localhost:8083/auth/login');

    print('Iniciando proceso de login...');
    print('URL: $url');
    print('Username: $username');
    print('Password: $password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'passwd': password}),
    );

    print('Estado de la respuesta: ${response.statusCode}');
    print('Cuerpo de la respuesta: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      print('Token recibido: $token');

      if (token != null) {
        await storage.write(key: 'jwt_token', value: token);
        print('Token almacenado con éxito');
        return true;
      } else {
        print('Token es nulo, fallo en la autenticación');
      }
    } else {
      print('Error en la autenticación. Código de estado: ${response.statusCode}');
    }
    return false;
  }

  Future<void> logout() async {
    print('Iniciando proceso de logout...');
    await storage.delete(key: 'jwt_token');
    print('Token eliminado');
  }

  Future<String?> getToken() async {
    print('Obteniendo token...');
    final token = await storage.read(key: 'jwt_token');
    print('Token obtenido: $token');
    return token;
  }
}