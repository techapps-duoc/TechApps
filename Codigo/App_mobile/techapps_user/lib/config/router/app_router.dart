import 'package:go_router/go_router.dart';
import 'package:techapps_user/screens/detalle_vehiculo_screen.dart';
import 'package:techapps_user/screens/login_screen.dart';
import 'package:techapps_user/screens/registrar_visitas_screen.dart';

final appRouter = GoRouter(
  routes: [

    GoRoute(
      path:'/',
      builder: (context,state) =>  const LoginScreen(),
    ),

    GoRoute(
      path:'/detalle_vehiculo',
      builder: (context,state) =>  const DetalleVehiculo(),
    ),

    GoRoute(
      path:'/registro_visita',
      builder: (context,state) =>  const RegistroVisita(),
    ),




  ]
);