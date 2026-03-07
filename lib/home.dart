import 'package:flutter/material.dart';
import './login.dart';

class Home extends StatelessWidget{
  final String studentID;
  const Home({super.key, required this.studentID});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to My NTHU Life')),
      body: const Center(child: Text('Hello Student ID: $studentID')),
    );
  }
}