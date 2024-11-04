import 'package:flutter/material.dart';

class BackgroundGeneral extends StatelessWidget {

 final Widget child;

  const BackgroundGeneral({
    super.key, 
    required this.child
    });


  @override
  Widget build(BuildContext context) {
    return SizedBox(

        // color: Colors.blue,
         width: double.infinity,
         height: double.infinity,
        child: Stack(
          children: [
        const _BlueBox(),
        //const _HeaderIconPerson(),
            child,
          ],
        ),
    );
  }
}

/*class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

 @override
  Widget build(BuildContext context) {
    return SafeArea(
    child:
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top:10),
      //  child:const Icon(Icons.car_repair_sharp,color: Colors.white, size:100,)
      )
    );
  }
} */

/*class _HeaderIconPerson extends StatelessWidget {
  const _HeaderIconPerson();

 @override
  Widget build(BuildContext context) {
    return SafeArea(
    child:
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top:10),
        child:const Icon(Icons.person,color: Colors.white, size:100,)
      )
    );
  }
} */

 class _BlueBox extends StatelessWidget {
  const _BlueBox();

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height *1.0,
      decoration: _blueBackground(),
      child: const Stack(
        children: [
         // _Bubble()
        ],
      ),
    );
  } 

  BoxDecoration _blueBackground() => const BoxDecoration(
     gradient: LinearGradient(
      colors:[
        Color.fromRGBO(9, 66, 147, 1),
        Color.fromRGBO(63,177,177,1)
      ]   
      )
  );
 }
