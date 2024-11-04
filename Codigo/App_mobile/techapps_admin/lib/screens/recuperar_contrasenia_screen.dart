import 'package:flutter/material.dart';

//import 'package:techapps_admin/config/router/app_router.dart';
import 'package:techapps_admin/widgets/widgets.dart';
import 'package:techapps_admin/ui/input_decorations.dart';
import 'package:go_router/go_router.dart';


class RecuperarContrasenia extends StatelessWidget{
  const RecuperarContrasenia({super.key});
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
                    //Text('Login', style: Theme.of(context).textTheme.headlineLarge,),
                    Text('Recuperar Contraseña', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
                    const SizedBox(height: 20),

                    _LoginForm(),
                  ],
                ),
              ),

              const SizedBox( height: 70),


          ]

            ,

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

            const SizedBox( height:50),

            MaterialButton(shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.green,
            child: Container(
              padding:  const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              child: const Text('Enviar',
              style:  TextStyle(color: Colors.white),
              )
            ),

            onPressed:(){
              context.go('/detalle_vehiculo_screen');
              //TODO LOGIN FROM
            } 
            )
              


          ],
        )
      ,) ,
    );
  }
}