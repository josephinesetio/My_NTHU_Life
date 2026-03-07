import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import './login.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, //Disables the debug banner
    home: Login(), //This sets the Login screen as the home screen
    );
  }
}

/* class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
  }
}
*/


