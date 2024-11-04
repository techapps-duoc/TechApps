 /*import 'package:flutter/material.dart';
import 'package:techapps_users/config/router/app_router.dart';
import 'package:techapps_users/widgets/widgets.dart';
import 'package:techapps_users/ui/input_decorations.dart';
import 'package:go_router/go_router.dart';


class LoginScreen extends StatelessWidget{
  const LoginScreen({super.key});
@override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Text('Login Residente', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 35)),
                    const SizedBox(height: 20),

                    _LoginForm(),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                disabledColor: Colors.grey,
                elevation: 0,
                color: Colors.green,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Text(
                    'Recuperar Contraseña',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onPressed: () {
                  context.go('/recuperar_contrasenia_screen');
                },
              ),

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

            const SizedBox( height:50),

            MaterialButton(shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.green,
            child: Container(
              padding:  const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              child: const Text('Ingresar',
              style:  TextStyle(color: Colors.white),
              )
            ),

            onPressed:(){
              context.go('/registro_visita');
              //TODO LOGIN FROM
            }
             )
          ],
        )
      ,) ,
    );
  }
} */

import 'package:flutter/material.dart';
//import 'package:techapps_users/util/snackbar.dart';
import 'package:techapps_users/widgets/widgets.dart';
import 'package:techapps_users/ui/input_decorations.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:techapps_users/services/AuthService.dart';



class LoginScreen extends StatelessWidget {
  static const String routename = 'Login';
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 250),
              CardContainer(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text('Login Usuario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35)),
                    const SizedBox(height: 20),
                    _LoginForm(),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                disabledColor: Colors.grey,
                elevation: 0,
                color: Colors.green,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Text(
                    'Recuperar Contraseña',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onPressed: () {
                  //context.go('/detalle_vehiculo');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService authService = AuthService();

    Future<void> _login() async {
    print('Intentando iniciar sesión con usuario: ${_usernameController.text}');
    final success = await authService.login(
      _usernameController.text,
      _passwordController.text,
    );
    if (success) {
      print('Login exitoso');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingreso realizado con éxito')),
      );
      //context.go('/detalle_vehiculo');
    } else {
      print('Login fallido');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al ingresar a Usuario, favor revisar credenciales.')),
      );
    }
  }

  /*Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Authentication using email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Navegar al home o pantalla deseada
      context.go('/detalle_vehiculo');
    } on FirebaseAuthException catch (e) {
     // String message = 'Error: ${e.message}';
      String message = 'Error: Ingreso de credenciales incorrectas';
      showSnackBar(context, message); // Muestra el error en un SnackBar
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _usernameController,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Ingrese Usuario',
                prefixIcon: Icons.alternate_email_rounded,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese usuario';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _passwordController,
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.text,
              decoration: InputDecorations.authInputDecoration(
                hintText: '******',
                labelText: 'Contraseña',
                prefixIcon: Icons.lock_outline,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su contraseña';
                }
                return null;
              },
            ),
            const SizedBox(height: 50),
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.green,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Ingresar',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
                onPressed:_login,
             // onPressed: _isLoading ? null : () => _login(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Liberar los controladores cuando se destruye el formulario
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
