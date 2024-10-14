import 'package:go_router/go_router.dart';
import 'package:techapps_admin/screens/detalle_vehiculo_screen.dart';
import 'package:techapps_admin/screens/login_screen.dart';
import 'package:techapps_admin/screens/recuperar_contrasenia_screen.dart';

/*import 'package:techapps_users/config/entity/album.dart';
import 'package:techapps_users/screens/detalle_vehiculo_screen.dart';
import 'package:techapps_users/screens/login_screen.dart';
import 'package:techapps_users/screens/registrar_visitas_screen.dart';
*/

final appRouter = GoRouter(
  routes: [

    GoRoute(
      path:'/',
      builder: (context,state) =>  const LoginScreen(),
    ),
    GoRoute(
      path:'/detalle_vehiculo_screen',
      builder: (context,state) =>  const DetalleVehiculo(),
    ),
    GoRoute(
      path:'/recuperar_contrasenia_screen',
      builder: (context,state) =>  const RecuperarContrasenia(),
    )

  ]
);