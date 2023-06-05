import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({Key key = const ValueKey('homepage')}) : super(key: key);
  final MaterialColor black = const MaterialColor(
    0xFF000000,
    <int, Color>{
      50: Color(0xFFE5E5E5),
      100: Color(0xFFBFBFBF),
      200: Color(0xFF999999),
      300: Color(0xFF737373),
      400: Color(0xFF4D4D4D),
      500: Color(0xFF262626),
      600: Color(0xFF1F1F1F),
      700: Color(0xFF191919),
      800: Color(0xFF121212),
      900: Color(0xFF0C0C0C),
    },
  );

 @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      theme: ThemeData(primarySwatch: black),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 46, 46, 46),
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Image.network(
                'https://download.memgraph.com/asset/playground/marvel-comics-background-fde3e300.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Image.asset('assets/images/inkLogo.png'),
                    SizedBox(
                      width: size.width * 0.8,
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white, // Cor de fundo do campo de login
                              hintText: 'Login',
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white70, // Cor de fundo do campo de senha
                              hintText: 'Senha',
                            ),
                            obscureText: true, // Oculta o texto digitado (senha)
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'Initial');
                            },
                            child: Text(
                              'Entrar',
                              style: TextStyle(fontSize: 50),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black, // Cor de fundo transparente
                              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0), // Borda arredondada
                                side: BorderSide(color: Colors.black), // Cor da borda
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
