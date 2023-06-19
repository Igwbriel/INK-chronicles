import 'package:flutter/material.dart';
import 'material/material_color.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key key = const ValueKey('homepage')}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RegExp passwordLenex = RegExp(
    r'^.{8,}$',
  );
  final RegExp passwordUpeex = RegExp(
    r'^.(?=.*[A-Z])',
  );
  final RegExp passwordNumex = RegExp(
    r'^.(?=.*[0-9])',
  );

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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Image.asset('assets/images/inkLogo.png'),
                      SizedBox(
                        width: size.width * 0.8,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white70.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: TextFormField(
                                controller: _loginController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your login';
                                  }
                                  if (!passwordNumex.hasMatch(value)) {
                                    return 'Login must have at one number';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white70,
                                  hintText: 'Login',
                                  border: InputBorder.none,
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white70.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (!passwordLenex.hasMatch(value)) {
                                    return 'Password must have at least 8 characters';
                                  }
                                  if (!passwordUpeex.hasMatch(value)) {
                                    return 'Password must have at one uppercase letter';
                                  }
                                  if (!passwordNumex.hasMatch(value)) {
                                    return 'Password must have at one number';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white70,
                                  hintText: 'Password',
                                  border: InputBorder.none,
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.pushNamed(context, 'Search');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: const BorderSide(color: Colors.black),
                                ),
                              ),
                              child: const Text(
                                'Enter',
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
            ),
          ],
        ),
      ),
    );
  }
}
