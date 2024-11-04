import 'package:flutter/material.dart';

class CardContainerForm extends StatelessWidget {
 
  final Widget child;

  const CardContainerForm({super.key,
   required this.child});

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Padding( 
      padding: const EdgeInsets.symmetric(horizontal: 30),
    child: 
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
     // height: 420,//780 le da el tamaño al card
      //height: size.height *1.0,
      height: 610,
      decoration: _createCardShapeForm(),
      child: child,
    ),
  );
  }

  BoxDecoration _createCardShapeForm() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(25),
    boxShadow: const [
      BoxShadow(
        color:  Colors.black12,
        blurRadius: 15,
        offset:  Offset(20,10)

      )
    ]
  );
}