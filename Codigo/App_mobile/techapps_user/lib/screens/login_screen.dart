import 'package:flutter/material.dart';
import 'package:techapps_user/config/router/app_router.dart';
import 'package:techapps_user/widgets/widgets.dart';
import 'package:techapps_user/ui/input_decorations.dart';
import 'package:go_router/go_router.dart';


class LoginScreen extends StatelessWidget{
  const LoginScreen({super.key});
@override
  Widget build(BuildContext context) {
    return Scaffold(
    /*  appBar: AppBar(
        title: const Text('Permisos'),
        actions: [
          IconButton(onPressed: (){
            //TODO SOLICITAR PERMISO D ENOTIFICACIONES


          },
          icon: const Icon(Icons.settings))
        ],
      ),*/

      body: AuthBackground(
        child:SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox( height: 250),
              CardContainer(
                child: Column(
                  children: [

                    const SizedBox( height: 10),
                    Text('Login', style: Theme.of(context).textTheme.headlineLarge,),
                    const SizedBox(height: 30),

                    _LoginForm(),
                  ],
                ),
              ),

              const SizedBox( height: 50),
              const Text('nueva cuenta')

            ],

          ),
        ) ,
      )
    );
  }
}


class _LoginForm extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
          //TODO:MANTENER REFERENCIA AL KEY
        child:Column(
          children: [

            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration:  InputDecorations.authInputDecoration(
               hintText: '',
                labelText: 'Ingrese Correo',
                prefixIcon: Icons.alternate_email_rounded
              ),
            ),

            const SizedBox(height: 30),

            TextFormField(
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
              decoration:  InputDecorations.authInputDecoration(
                hintText: '******',
                labelText: 'Contraseña',
                prefixIcon: Icons.lock_outline
              ),
            ),

            const SizedBox( height:20),

            MaterialButton(shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.deepPurple,
            child: Container(
              padding:  const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              child: const Text('Ingresar',
              style:  TextStyle(color: Colors.white),
              )
            ),

            onPressed:(){
              context.go('/detalle_vehiculo');
              //TODO LOGIN FROM
            }
             )
          ],
        )
      ,) ,
    );
  }
}