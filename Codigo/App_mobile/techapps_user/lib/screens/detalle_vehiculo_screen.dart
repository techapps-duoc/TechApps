import 'package:flutter/material.dart';
import 'package:techapps_user/widgets/background_general.dart';
import 'package:techapps_user/widgets/card_container_form.dart';
import 'package:techapps_user/widgets/widgets.dart';
import 'package:techapps_user/ui/input_decorations.dart';
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
              const SizedBox( height: 280),
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


class _FormDetalleVehiculo extends StatelessWidget {

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
                labelText: 'Patente',
                prefixIcon: Icons.numbers
              ),
            ),

            const SizedBox(height: 30),

            TextFormField(
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
              decoration:  InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Tipo Vehiculo',
                prefixIcon: Icons.car_repair
              ),
            ),

            const SizedBox(height: 30),

             TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration:  InputDecorations.authInputDecoration(
               hintText: '',
                labelText: 'Marca',
                prefixIcon: Icons.auto_mode_outlined
              ),
            ),

            const SizedBox(height: 30),

            
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration:  InputDecorations.authInputDecoration(
               hintText: '',
                labelText: 'Color',
                prefixIcon: Icons.color_lens
              ),
            ),


            const SizedBox(height: 30),

             TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration:  InputDecorations.authInputDecoration(
               hintText: '',
                labelText: 'Dueño del Vehiculo',
                prefixIcon: Icons.person
              ),
            ),

            const SizedBox(height: 30),

            MaterialButton(shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.blueGrey,
            child: Container(
              padding:  const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              child: const Text('Confirmar',
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