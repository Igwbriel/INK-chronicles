import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ink_chronicles/matrial/material_color.dart';
import 'initialpage.dart';
import 'dart:convert';

var data = DataService();

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

class ResultDetailPage extends StatelessWidget {
  final String result;
  var chaves = ["name", "style", "ibu"];
  var colunas = ["Nome", "Estilo", "IBU"];

  ResultDetailPage({required this.result});
  

  Widget searchCharacters(String? nameSearch) {
    final ValueNotifier<Map<String, dynamic>> tableStateNotifier =
      ValueNotifier({'status': TableStatus.idle, 'dataObjects': []});
    tableStateNotifier.value = {
      'status': TableStatus.loading,
      'dataObjects': [],
      'columnNames': [],
    };
    void columnCharacters() {

    chaves = [
      "name",
      "origin",
      "publisher",
      "image",
      "real_name",
      "count_of_issue_appearances",
      "deck",
      "ID"
    ];
    colunas = [
      "Nome",
      "Origem",
      "Editora",
      "perfil",
      "Identidade",
      "contagem",
      "resumo",
      "id"
    ];
  }
    var charactersUri = Uri(
      scheme: 'https',
      host: 'comicvine.gamespot.com',
      path: 'api/characters',
      queryParameters: {
        //'limit': 100, // Adjust this value accordingly
        'api_key': '75504a0c3fdb9bb78d69b682d9e39fa478d71195',
        'format': 'json',
      },
    );

    return FutureBuilder<String>(
      future: http.read(charactersUri),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child:CircularProgressIndicator(),);
        } else if (snapshot.hasError) {
          return Text('Erro ao carregar os dados');
        } else {
          var charactersJson = jsonDecode(snapshot.data!)['results'];

          var extractedCharactersJson = charactersJson.map((character) {
        final name = character['name'] ?? '';
        final origin =
            character['origin'] != null ? character['origin']['name'] : '';
        final publisher = character['publisher'] != null
            ? character['publisher']['name']
            : '';
        final image =
            character['image'] != null ? character['image']['icon_url'] : '';
        final realName = character['real_name'] ?? '';
        final ID = character['id'] ?? '';
        final contagem = character['count_of_issue_appearances'] ?? '';
        final resumo = character['deck'] ?? '';

          return {
          'name': name,
          'origin': origin,
          'publisher': publisher,
          'image': image,
          'real_name': realName,
          'id': ID,
          'count_of_issue_appearances': contagem,
          'deck': resumo,
        };
      }).toList();
      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': extractedCharactersJson,
        'propertyNames': ["name", "origin", "publisher", "image"],
      };

          var filteredCharactersJson = extractedCharactersJson
              .where((character) => character['name'] == (result))
              .toList();

          if (filteredCharactersJson.isEmpty) {
            return Text('Nenhum resultado encontrado.');
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: filteredCharactersJson.length,
              itemBuilder: (BuildContext context, int index) {
                final character = filteredCharactersJson[index];
                return ListTile(
                  title: Text(character['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Origin: ${character['origin']}'),
                      Text('Publisher: ${character['publisher']}'),
                      Text('Real Name: ${character['real_name']}'),
                      Text('Numero de aparições : ${character['count_of_issue_appearances']}'),
                      Text('Resumo : ${character['deck']}'),
                    ],
                  ),
                  leading: Image.network(character['image']),
                );
              },
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Resultado'),
      ),
      body: searchCharacters(result),
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
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredData = _data;
    _fetchImages();
    _populateData(); // Call the method to populate the _data list
  }

  void _handleResultSelected(String result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultDetailPage(result: result),
      ),
    );
  }  

  void _populateData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://comicvine.gamespot.com/api/characters/?api_key=75504a0c3fdb9bb78d69b682d9e39fa478d71195&format=json'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> results = jsonData['results'];

        setState(() {
          _data = results.map((result) => result['name'] as String).toList();
          _filteredData = _data;
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch data: $e');
    }
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

  void _handleSearchSubmitted(String value) {
    _filterSearchResults(value);

  }

  Widget _buildCarousel() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Transform.scale(
        scale: 2.0,
        child: CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 16 / 9,
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
                    fit: BoxFit.none,
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
        controller: _searchController,
        onSubmitted: _handleSearchSubmitted,
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
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
            onPressed: () {
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

  Widget _buildSearchResults() {
  if (_filteredData.isEmpty) {
    return Text(
      'Nenhum resultado encontrado.',
      style: TextStyle(fontSize: 16.0),
    );
  } else {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _filteredData.length,
      itemBuilder: (BuildContext context, int index) {
        final String result = _filteredData[index];
        return GestureDetector(
          onTap: () {
            _handleResultSelected(result);
          },
          child: ListTile(
            title: Text(result),
            // Add any other information you want to display for each result
          ),
        );
      },
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildLogo(),
            _buildCarousel(),
            _buildSearch(),
            _buildButtons(),
            _buildSearchResults(),
          ],
        ),
      ),
    );
  }
}
