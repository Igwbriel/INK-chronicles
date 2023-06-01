import 'package:flutter/material.dart';
import 'initialpage.dart';
import 'homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key = const ValueKey('homepage')}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(initialRoute: '/', routes: {
      '/': (context) => Homepage(),
      'Initial': (context) => Apis(),
    });
  }
}
