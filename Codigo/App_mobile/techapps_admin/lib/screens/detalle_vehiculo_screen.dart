import 'package:flutter/material.dart';
import 'package:techapps_admin/widgets/background_general.dart';
import 'package:techapps_admin/widgets/card_container_form.dart';
//import 'package:techapps_admin/widgets/widgets.dart';
import 'package:techapps_admin/ui/input_decorations.dart';
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

              const SizedBox( height: 10),//distancia entre vehiculo y card
              CardContainerForm(
                child: Column(
                  children: [
                    
                    _FormDetalleVehiculo(),
                  ],
                ),
              ),

              const SizedBox( height:10),
        
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
        child:const Icon(Icons.car_repair_sharp,color: Colors.white, size:130,)
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

            Text('Datos de Visita', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30)),
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

            const SizedBox(height: 10),

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

            const SizedBox(height: 10),

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

            const SizedBox(height: 10),

            
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


            const SizedBox(height: 10),

             TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.text,
              decoration:  InputDecorations.authInputDecoration(
               hintText: '',
                labelText: 'Nombre Residente',
                prefixIcon: Icons.person
              ),
              style: TextStyle(fontSize: 20),
            ),

              const SizedBox(height: 10),

            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.text,
              decoration:  InputDecorations.authInputDecoration(
               hintText: '',
                labelText: 'Torre',
                prefixIcon: Icons.home_filled
              ),
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),


          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
            MaterialButton(shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.green,
            child: Container(
              padding:  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: const Text('Consultar',
              style:  TextStyle(color: Colors.white),
              )
            ),
            onPressed:(){
                context.go('/registro_visita');
              //TODO LOGIN FROM
            }
          ),

          SizedBox(width: 20),

          MaterialButton(shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.blueAccent,
            child: Container(
              padding:  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: const Text('Aceptar',
              style:  TextStyle(color: Colors.white),
              )
            ),
            onPressed:(){
                context.go('/registro_visita');
              //TODO LOGIN FROM
            }
          )



          
          ]
          )
           )
          ],
        )
      ,) ,
    );
  }
}