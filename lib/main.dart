import 'package:flutter/material.dart';
import 'home.dart';

// This is the main file to be run. It calls Generator() from home.dart, which contains the logic and UI elements of the Flutter app
void main() {

  runApp(
    MaterialApp(
      title: 'Generative AI App',
      home: Generator(),
    )
  );
}


