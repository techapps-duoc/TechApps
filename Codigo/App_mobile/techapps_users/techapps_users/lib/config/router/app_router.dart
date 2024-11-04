import 'package:go_router/go_router.dart';
import 'package:techapps_users/config/entity/album.dart';
import 'package:techapps_users/screens/detalle_vehiculo_screen.dart';
import 'package:techapps_users/screens/login_screen.dart';
import 'package:techapps_users/screens/registrar_visitas_screen.dart';
import 'package:techapps_users/screens/recuperar_contrasenia_screen.dart';

final appRouter = GoRouter(
  routes: [

    GoRoute(
      path:'/',
      builder: (context,state) =>  LoginScreen(),
    ),

    GoRoute(
      path:'/detalle_vehiculo',
      builder: (context,state) =>  const DetalleVehiculo(),
    ),

    GoRoute(
      path:'/registro_visita',
      builder: (context,state) =>  const RegistroVisita(),
    ),

    GoRoute(
      path:'/album_tester',
      builder: (context,state) =>  const MyApp(),
    ),

    GoRoute(
      path:'/recuperar_contrasenia_screen',
      builder: (context,state) =>  const RecuperarContrasenia(),
    ),




  ]
);