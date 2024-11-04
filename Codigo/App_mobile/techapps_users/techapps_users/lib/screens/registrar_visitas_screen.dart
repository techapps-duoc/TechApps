import 'package:flutter/material.dart';
import 'package:techapps_users/widgets/background_general.dart';
import 'package:techapps_users/widgets/card_container_form.dart';
import 'package:techapps_users/widgets/widgets.dart';
import 'package:techapps_users/ui/input_decorations.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:go_router/go_router.dart';
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



/* version buena
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

            Text("Información de la visita"),
            TextFormField(
              autocorrect: false,
             // keyboardType: TextInputType.text,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Rut',
                prefixIcon: Icons.card_membership,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.text,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Primer Nombre',
                prefixIcon: Icons.person,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              obscureText: false,
              keyboardType: TextInputType.text,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Apellidos',
                prefixIcon: Icons.family_restroom,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.text,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Patente',
                prefixIcon: Icons.numbers,
              ),
            ),

            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.text,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Marca',
                prefixIcon: Icons.auto_mode_outlined,
              ),
            ),

            const SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.text,
              decoration: InputDecorations.authInputDecoration(
                hintText: '',
                labelText: 'Modelo',
                prefixIcon: Icons.model_training,
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
      fin version buena*/

  class RegistroVisita extends StatelessWidget {
  const RegistroVisita({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGeneral(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _HeaderIconPerson(),
              const SizedBox(height: 20),
              CardContainerForm(
                child: _FormRegistroVisita(),
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
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
        child: const Icon(Icons.person, color: Colors.white, size: 150),
      ),
    );
  }
}

class _FormRegistroVisita extends StatefulWidget {
  @override
  __FormRegistroVisitaState createState() => __FormRegistroVisitaState();
}

class __FormRegistroVisitaState extends State<_FormRegistroVisita> {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Información de la visita", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._buildTextFormFields(),
            const SizedBox(height: 10),
            _buildDateButton(context),
            const SizedBox(height: 10),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTextFormFields() {
    return [
      _buildCustomTextField(labelText: 'Rut', icon: Icons.card_membership),
      _buildCustomTextField(labelText: 'Primer Nombre', icon: Icons.person),
      _buildCustomTextField(labelText: 'Apellidos', icon: Icons.family_restroom),
      _buildCustomTextField(labelText: 'Patente', icon: Icons.numbers),
      _buildCustomTextField(labelText: 'Marca', icon: Icons.auto_mode_outlined),
      _buildCustomTextField(labelText: 'Modelo', icon: Icons.model_training),
    ];
  }

  Widget _buildCustomTextField({required String labelText, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        decoration: InputDecorations.authInputDecoration(
          hintText: '',
          labelText: labelText,
          prefixIcon: icon,
        ),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildDateButton(BuildContext context) {
    return Row(
      children: [
        MaterialButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.blue,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              'Fecha de visita',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          onPressed: () {
            _seleccionarFecha(context);
          },
        ),
        const SizedBox(width: 10),
        Text(
          _date == null
              ? '00/00/0000'
              : '${_date!.day}/${_date!.month}/${_date!.year}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return MaterialButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.green,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        child: Text(
          'Guardar',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      onPressed: () {
        context.go('/album_tester');
      },
    );
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _date = fechaSeleccionada;
      });
    }
  }
}
