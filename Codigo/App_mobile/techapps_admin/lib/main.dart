import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:techapps_admin/config/router/app_router.dart';
import 'package:techapps_admin/firebase_options.dart';
import 'package:techapps_admin/preferences/pref_usuarios.dart';

void main() async {

WidgetsFlutterBinding.ensureInitialized();
await PreferenciasUsuarios.init();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  final prefs = PreferenciasUsuarios();

 @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      //theme: AppsTheme.blue,
    );
  }

   Future<String> obtenerUltimaPagina() async {
    // Aquí se podría obtener la preferencia del usuario para la ruta
    final ruta =  prefs.ultimaPagina;
    return ruta ?? '/'; // Ruta por defecto si no hay preferencia
  }


}
