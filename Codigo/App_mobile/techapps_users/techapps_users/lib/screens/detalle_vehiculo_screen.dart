import 'package:flutter/material.dart';
import 'package:techapps_users/widgets/background_general.dart';
import 'package:techapps_users/widgets/card_container_form.dart';
import 'package:techapps_users/widgets/widgets.dart';
import 'package:techapps_users/ui/input_decorations.dart';
import 'package:go_router/go_router.dart';

class DetalleVehiculo extends StatelessWidget{
  const DetalleVehiculo({super.key});
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGeneral(
        child:SingleChildScrollView(
          child: Column(
            children: [
              _HeaderIconVehiculo(),
              const SizedBox( height: 20),
              CardContainerForm(
                child: Column(
                  children: [

                   /* const SizedBox( height: 10),
                    Text('Login', style: Theme.of(context).textTheme.headlineLarge,),
                    const SizedBox(height: 30),*/
                    
                    _FormDetalleVehiculo(),
                  ],
                ),
              ),

              const SizedBox( height:20),
        
            ],

          ),
        ) ,
      )
    );
  }
}

class _HeaderIconVehiculo extends StatelessWidget {
  const _HeaderIconVehiculo();

 @override
  Widget build(BuildContext context) {
    return SafeArea(
    child:
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top:10),
        child:const Icon(Icons.car_repair_sharp,color: Colors.white, size:150,)
      )
    );
  }
}


class _FormDetalleVehiculo extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
          //TODO:MANTENER REFERENCIA AL KEY
        child:Column(
          children: [

            Text('Datos del Vehiculo', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30)),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.text,
              decoration:  InputDecorations.authInputDecoration(
               hintText: '',
                labelText: 'Patente',
                prefixIcon: Icons.numbers
              ),
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            TextFormField(
              autocorrect: false,
              //obscureText: true, se utiliza para no mostrar caracteres contraseñas
              keyboardType: TextInputType.text,
              decoration:  InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Tipo Vehiculo',
                prefixIcon: Icons.car_repair
              ),
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

             TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.text,
              decoration:  InputDecorations.authInputDecoration(
               hintText: '',
                labelText: 'Marca',
                prefixIcon: Icons.auto_mode_outlined
              ),
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.text,
              decoration:  InputDecorations.authInputDecoration(
               hintText: '',
                labelText: 'Color',
                prefixIcon: Icons.color_lens
              ),
              style: TextStyle(fontSize: 20),
            ),


            const SizedBox(height: 20),

             TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.text,
              decoration:  InputDecorations.authInputDecoration(
               hintText: '',
                labelText: 'Dueño del Vehiculo',
                prefixIcon: Icons.person
              ),
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 40),

            MaterialButton(shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.green,
            child: Container(
              padding:  const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              child: const Text('Confirmar Datos',
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
}