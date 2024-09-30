import 'package:flutter/material.dart';
import 'package:techapps_user/widgets/background_general.dart';
import 'package:techapps_user/widgets/card_container_form.dart';
import 'package:techapps_user/widgets/widgets.dart';
import 'package:techapps_user/ui/input_decorations.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
/*
class RegistroVisita extends StatelessWidget{
  const RegistroVisita({super.key});
  
  
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGeneral(
        child:SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox( height: 40),//le da la posicion de inicio vertical
              CardContainerForm(
                child: Column(
                  children: [

                   /* const SizedBox( height: 10),
                    Text('Login', style: Theme.of(context).textTheme.headlineLarge,),
                    const SizedBox(height: 30),*/

                    _FormRegistroVisita(),
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


class _FormRegistroVisita extends StatelessWidget {

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
                labelText: 'Rut',
                prefixIcon: Icons.numbers
              ),
            ),

            const SizedBox(height: 20),


            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration:  InputDecorations.authInputDecoration(
               hintText: '',
                labelText: 'Nombre',
                prefixIcon: Icons.abc
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
              decoration:  InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Apellido Paterno',
                prefixIcon: Icons.abc_sharp
              ),
            ),

            const SizedBox(height: 20),

             TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration:  InputDecorations.authInputDecoration(
               hintText: '',
                labelText: 'Apellido Materno',
                prefixIcon: Icons.abc
              ),
            ),

            const SizedBox(height: 20),


         /*   SizedBox(
              
                  width: 300,
                  height: 350,
                  child: DatePicker(
                  minDate: DateTime(2021, 1, 1),
                  maxDate: DateTime(2023, 12, 31),
                  onDateSelected: (value) {
                    // Handle selected date
                  },
                ),
                ),
*/

            MaterialButton(shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.blueGrey,
            child: Container(
              padding:  const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              child: const Text('Seleccione fecha',
              style:  TextStyle(color: Colors.white),
              )
            ),
            onPressed:(){
                
              _selecccionarFecha(context);
            }
             ),


            const SizedBox(height: 10),

            MaterialButton(shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.blueGrey,
            child: Container(
              padding:  const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              child: const Text('Guardar',
              style:  TextStyle(color: Colors.white),
              )
            ),


            

            onPressed:(){
                
              //TODO LOGIN FROM
            }
             )
          ],
        )
      ,) ,
    );
  }

        Future<void> _selecccionarFecha () async {

          
          DateTime? _fechaSeleccionada= await showDatePicker(
            context:context,
            initialDate:DateTime(1900),
            firstDate: DateTime.now(),
            lastDate: DateTime.now());
        }


}*/


// segundo codigo se puede seleccionar fecha pero no mostrar en un texto


/*
class RegistroVisita extends StatelessWidget {
  const RegistroVisita({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGeneral(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              CardContainerForm(
                child: Column(
                  children: [
                    _FormRegistroVisita(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormRegistroVisita extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        //TODO: MANTENER REFERENCIA AL KEY
        child: Column(
          children: [
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Rut',
                prefixIcon: Icons.numbers,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Nombre',
                prefixIcon: Icons.abc,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Apellido Paterno',
                prefixIcon: Icons.abc_sharp,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Apellido Materno',
                prefixIcon: Icons.abc,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Fecha seleccionada',
            style:TextStyle(
              fontWeight:  FontWeight.bold,
              fontSize:38
            )
              
            ),

              Text(
              _date ==null
              ? 'Ninguna fecha seleccionada'
              :'${_date.day}/${_date.month}/${_date.year}',
              style:TextStyle(
              fontWeight:  FontWeight.bold,
              fontSize:38
            )
              
            ),

            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.blueGrey,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                child: const Text(
                  'Seleccione fecha',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed: () {
                _selecccionarFecha(context); // Llama al método pasando el contexto
              },
            ),

           
            const SizedBox(height: 10),
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.blueGrey,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed: () {
                // TODO: Implementar lógica para guardar
              },
            ),
          ],
        ),
      ),
    );
  }
   var _date =null;
  Future<void> _selecccionarFecha(BuildContext context) async {
    DateTime? _fechaSeleccionada = await showDatePicker(
      context: context, // Usa el contexto pasado como argumento
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    
  
    if (_fechaSeleccionada != null) {
      // Aquí puedes manejar la fecha seleccionada
      _fechaSeleccionada=_date;
    }




  }

}
*/
class RegistroVisita extends StatelessWidget {
  const RegistroVisita({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGeneral(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 190),
              CardContainerForm(
                child: Column(
                  children: [


                    _HeaderIcon(),
                    _FormRegistroVisita(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}




class _FormRegistroVisita extends StatefulWidget {
  @override
  __FormRegistroVisitaState createState() => __FormRegistroVisitaState();
}

class __FormRegistroVisitaState extends State<_FormRegistroVisita> {
  DateTime? _date; // Variable para almacenar la fecha seleccionada

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        child: Column(
          children: [
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Rut',
                prefixIcon: Icons.numbers,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Nombre',
                prefixIcon: Icons.abc,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Apellido Paterno',
                prefixIcon: Icons.abc_sharp,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Apellido Materno',
                prefixIcon: Icons.abc,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children:<Widget>[

                MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.blueGrey,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: const Text(
                  'Fecha de visita',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed: () {
                _selecccionarFecha(context); // Llama al método pasando el contexto
              },
            ),

          /*  const Text(
              'Fecha seleccionada',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),*/
          Padding(
            padding: EdgeInsets.symmetric(horizontal:15),
             child: Text(
              _date == null
                  ? '00/00/0000'
                  : '${_date!.day}/${_date!.month}/${_date!.year}',
              style: TextStyle(  
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          )

       ],

    ),

            const SizedBox(height: 20),

            const SizedBox(height: 10),
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.blueGrey,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed: () {
                // TODO: Implementar lógica para guardar
              },
            ),
          ],
        ),
      ),
    );


  }

  Future<void> _selecccionarFecha(BuildContext context) async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _date = fechaSeleccionada; // Actualiza la fecha seleccionada
      });
    }
  }


  
}