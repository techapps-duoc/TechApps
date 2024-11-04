import 'package:flutter/material.dart';
import 'package:techapps_admin/widgets/widgets.dart';
import 'package:techapps_admin/ui/input_decorations.dart';
import 'package:go_router/go_router.dart';
import 'package:techapps_admin/config/services/AuthService.dart';



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
                    Text('Login Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35)),
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
                  context.go('/detalle_vehiculo');
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
      //Navigator.pushReplacementNamed(context, '/detalle_vehiculo'); no me redirige a la pantalla de detalle de vehiculo al login exitoso
      context.go('/detalle_vehiculo');
    } else {
      print('Login fallido');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al ingresar a Admin, favor revisar credenciales.')),
      );
    }
  }

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
                labelText: 'Ingrese Correo',
                prefixIcon: Icons.alternate_email_rounded,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su correo';
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
