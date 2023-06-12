import 'package:flutter/material.dart';
import 'initialpage.dart';
import 'homepage.dart';
import 'search_page.dart';
class MyApp extends StatelessWidget {
  const MyApp({Key key = const ValueKey('homepage')}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(initialRoute: 'Search'
    , routes: {
      '/': (context) => Homepage(),
      'Initial': (context) => Apis(),
      'Search': (context)=> SearchBarApp(),
    });
  }
}