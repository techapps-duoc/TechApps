import 'package:go_router/go_router.dart';
import 'package:techapps_admin/screens/detalle_vehiculo_screen.dart';
import 'package:techapps_admin/screens/login_screen.dart';
import 'package:techapps_admin/screens/recuperar_contrasenia_screen.dart';


final appRouter = GoRouter(
  routes: [

//utilizado como primera pantalla
    GoRoute(
      path:'/',
      builder: (context,state) =>  LoginScreen(), 
    ),

//pantalla de ingreso de visita
    GoRoute(
      path: '/detalle_vehiculo',
      builder: (context,state) =>  VehiculoScreen(),
      ),
    
//pantalla cambio de contrasenia
    GoRoute(
      path:'/recuperar_contrasenia_screen',
      builder: (context,state) =>  const RecuperarContrasenia(),
    ),
  ]
);