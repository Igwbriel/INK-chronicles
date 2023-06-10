import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'matrial/material_color.dart';
import 'initialpage.dart';



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
  final List<String> _imageUrls = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRnt_1wHhAK_Pwcld6j63uGIcnq93Xo931giw',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvqoGSZ8qg73v8Ogb3Sm7M145zyUdek2LiYw',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTyI31daDS2caW9D15Fl8E7Ocbo7pypNYUUyw',
    'data:image/jpeg;base64,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',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQm4svmWHnzwJPEvuayhyBoSuicmig2knroSikhfxPj0zxDeB4l-LePcqy0ZDpDni0psRk',
  ];
  @override
  void initState() {
    super.initState();
    _filteredData = _data;
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

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 15 / 5,
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
                fit: BoxFit.fill,
              ),
            );
          },
        );
      }).toList(),
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
          _filterSearchResults(value);
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
    height: 120, // Defina uma altura adequada para o grid
    child: GridView.count(
      crossAxisCount: 5,
      childAspectRatio: 2.0,
      padding: const EdgeInsets.all(16.0),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      children: [
          ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200.0), // Define o raio da borda circular
            ),
          ),
          onPressed: () {
            // Implemente a funcionalidade para o botão "Character's"
            Navigator.pushNamed(context, 'Initial');
          },
          child: const Text(
            'Character\'s',
            style: TextStyle(
              fontSize: 16.0,
              decoration: TextDecoration.underline,
            ),
          ),
        ),  
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200.0), // Define o raio da borda circular
            ),
          ),
          onPressed: () {
            // Implemente a funcionalidade para o botão "Character's"
          },
          child: const Text(
            'Publisher\'s',
            style: TextStyle(
              fontSize: 16.0,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200.0), // Define o raio da borda circular
            ),
          ),
          onPressed: () {
            // Implemente a funcionalidade para o botão "Character's"
          },
          child: const Text(
            'Team\'s',
            style: TextStyle(
              fontSize: 16.0,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200.0), // Define o raio da borda circular
            ),
          ),
          onPressed: () {
            // Implemente a funcionalidade para o botão "Character's"
            
          },
          child: const Text(
            'Series',
            style: TextStyle(
              fontSize: 16.0,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200.0), // Define o raio da borda circular
            ),
          ),
          onPressed: () {
            // Implemente a funcionalidade para o botão "Character's"
          },
          child: const Text(
            'Volume\'s',
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
            _buildSearch(),
            _buildCarousel(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }
}
