import 'package:flutter/material.dart';
import 'package:ink_chronicles/matrial/material_color.dart';

class Homepage extends StatelessWidget {
  const Homepage({Key key = const ValueKey('homepage')}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      theme: ThemeData(primarySwatch: black),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 46, 46, 46),
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
                          const TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors
                                  .white, // Cor de fundo do campo de login
                              hintText: 'Login',
                            ),
                          ),
                          const SizedBox(height: 10),
                          const TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors
                                  .white70, // Cor de fundo do campo de senha
                              hintText: 'Senha',
                            ),
                            obscureText:
                                true, // Oculta o texto digitado (senha)
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'Search');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Cor de fundo transparente
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    18.0), // Borda arredondada
                                side: const BorderSide(
                                    color: Colors.black), // Cor da borda
                              ),
                            ),
                            child: const Text(
                              'Entrar',
                              style: TextStyle(fontSize: 50),
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
