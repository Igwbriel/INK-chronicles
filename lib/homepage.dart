import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({Key key = const ValueKey('homepage')}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 46, 46, 46),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset('assets/images/inkLogo.png'),
              SizedBox(
                width: size.width * 0.8,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'Initial');
                  },
                  child: Text('Entrar', style: TextStyle(fontSize: 50)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
