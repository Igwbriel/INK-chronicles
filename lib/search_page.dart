import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ink_chronicles/matrial/material_color.dart';
import 'initialpage.dart';
import 'dart:convert';

class SearchBarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'Initial': (context) => Apis(),
      },
      title: 'Search Bar',
      theme: ThemeData(
        primarySwatch: black,
      ),
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchText = "";
  List<String> _data = [];
  List<String> _filteredData = [];
  List<String> _imageUrls = [];
  @override
  void initState() {
    super.initState();
    _filteredData = _data;
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    try {
      final response = await http.get(Uri.parse(
          'https://comicvine.gamespot.com/api/volumes/?api_key=75504a0c3fdb9bb78d69b682d9e39fa478d71195&format=json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        final List<dynamic> data = responseData['results'];
        final List<String> imageUrls = [];

        for (final item in data) {
          final String imageUrl = item['image']['icon_url'];
          imageUrls.add(imageUrl);
        }

        setState(() {
          _imageUrls = imageUrls;
        });
      } else {
        print('Failed to fetch images: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch images: $e');
    }

    void _filterSearchResults(String query) {
      List<String> filteredList = [];
      filteredList.addAll(_data);
      if (query.isNotEmpty) {
        filteredList.retainWhere(
            (item) => item.toLowerCase().contains(query.toLowerCase()));
      }

      setState(() {
        _searchText = query;
        _filteredData = filteredList;
      });
    }
  }

  Widget _buildCarousel() {
    return SizedBox(
      width: 200, //Gabriel mo fi
      height: 200, //Gabriel mo fi
      child: Transform.scale(
        scale: 2, //Gabriel mo fi
        child: CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 16 / 9, //Gabriel mo fi
            autoPlayCurve: Curves.fastOutSlowIn,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            enableInfiniteScroll: true,
            pauseAutoPlayOnTouch: true,
            scrollDirection: Axis.horizontal,
          ),
          items: _imageUrls.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.none, //Gabriel mo fi
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 150,
      height: 100,
      child: Transform.scale(
        scale: 1.0,
        child: Image.asset('assets/images/inkLogo.png'),
      ),
    );
  }

  

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) {
          
        },
        decoration: const InputDecoration(
          labelText: 'Search',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    50.0), // Define o raio da borda circular
              ),
            ),
            onPressed: () {
              // Implemente a funcionalidade para o primeiro botão
              Navigator.pushNamed(context, 'Initial');
            },
            child: const Text(
              'Todos',
              style: TextStyle(
                fontSize: 16.0,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildLogo(),
            _buildCarousel(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }
}
