import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {

 final Widget child;

  const AuthBackground({
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

            const _HeaderIcon(),

            child,
          ],
        ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
    child:
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top:20),
        //child:const Icon(Icons.person_pin,color: Colors.white, size:150)
        child: Image.asset('assets/usuario.png', width:200.0, height: 200.0),
      )
    );
  }
}

 class _BlueBox extends StatelessWidget {
  const _BlueBox();

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height *0.4,
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