/*
 Hbiliatat formulario regisro de visita
import 'package:flutter/material.dart';
import 'package:techapps_users/widgets/background_general.dart';
import 'package:techapps_users/widgets/card_container_form.dart';
import 'package:techapps_users/widgets/widgets.dart';
import 'package:techapps_users/ui/input_decorations.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:go_router/go_router.dart';

class RegistroVisita extends StatelessWidget {
  const RegistroVisita({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGeneral(
        child: SingleChildScrollView(
          child: Column(
            children: [

              _HeaderIconPerson(),
              const SizedBox(height: 20),
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


class _HeaderIconPerson extends StatelessWidget {
  const _HeaderIconPerson();

 @override
  Widget build(BuildContext context) {
    return SafeArea(
    child:
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top:10),
        child:const Icon(Icons.person,color: Colors.white, size:150,)
      )
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
              keyboardType: TextInputType.text,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Rut',
                prefixIcon: Icons.numbers,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.text,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Nombre',
                prefixIcon: Icons.abc,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              obscureText: false,
              keyboardType: TextInputType.text,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Apellido Paterno',
                prefixIcon: Icons.abc_sharp,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.text,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Apellido Materno',
                prefixIcon: Icons.abc,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children:<Widget>[

                //Icon(Icons.date_range, color: Colors.deepPurple, size:20),
                MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.blue,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: const Text(
                  'Fecha de visita',
                  style: TextStyle(color: Colors.white, fontSize: 15),
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
            padding: EdgeInsets.symmetric(horizontal:10),
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

            const SizedBox(height: 80),

            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.green,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.white, fontSize:20),
                
                ),
              ),
              onPressed: () {
                // TODO: Implementar lógica para guardar
                context.go('/album_tester');
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
      //firstDate: DateTime(1900),
      //lastDate: DateTime.now(),
     firstDate: DateTime.now() ,
     lastDate: DateTime.now().add(Duration(days: 7)), 
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _date = fechaSeleccionada; // Actualiza la fecha seleccionada
      });
    }
  }


  
}

*/