
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void showSnackBar(BuildContext context , String mensaje){

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(mensaje),
              duration: Duration(milliseconds: 5000)),
    );
}