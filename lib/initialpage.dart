// ignore_for_file: must_be_immutable, non_constant_identifier_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum TableStatus { idle, loading, ready, error }

class DataService {
  List<bool> isLoading = [false, false, false];
  int currentIndex = 0;
  final ValueNotifier<Map<String, dynamic>> tableStateNotifier =
      ValueNotifier({'status': TableStatus.idle, 'dataObjects': []});

  var chaves = ["name", "style", "ibu"];
  var colunas = ["Nome", "Estilo", "IBU"];
  var quantidadeItens = 1000;

  void columnCharacters() {
    currentIndex = 0;
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

  void columnIssues() {
    currentIndex = 1;
    chaves = ["name", "volume", "deck", "issue_number", "image"];
    colunas = ["Nome", "vol", "about", "numero", "image"];
  }

  void columnPublishers() {
    currentIndex = 2;
    chaves = ["name", "location_state", "location_city", "image"];
    colunas = ["Nome", "Estado", "Cidade", "Logo"];
  }

  void carregar(index) {
    if (isLoading[index]) return;
    final funcoes = [
      carregarCharacters,
      carregarIssues,
      carregarPublishers,
    ];
    tableStateNotifier.value = {
      'status': TableStatus.loading,
      'dataObjects': [],
      'columnNames': [],
    };
    funcoes[index]();
  }

  void carregarCharacters() {
    columnCharacters();
    isLoading[0] = true;
    var charactersUri = Uri(
      scheme: 'https',
      host: 'comicvine.gamespot.com',
      path: 'api/characters',
      queryParameters: {
        'limit': quantidadeItens.toString(),
        'api_key': '75504a0c3fdb9bb78d69b682d9e39fa478d71195',
        'format': 'json'
      },
    );

    http.read(charactersUri).then((jsonString) {
      var charactersJson = jsonDecode(jsonString)['results'];

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
      isLoading[0] = false;
    });
  }

  void carregarIssues() {
    columnIssues();
    isLoading[1] = true;
    var issuesUri = Uri(
      scheme: 'https',
      host: 'comicvine.gamespot.com',
      path: 'api/issues',
      queryParameters: {
        'limit': quantidadeItens.toString(),
        'api_key': '75504a0c3fdb9bb78d69b682d9e39fa478d71195',
        'format': 'json'
      },
    );

    http.read(issuesUri).then((jsonString) {
      var issuesJson = jsonDecode(jsonString)['results'];

      var extractedIssuesJson = issuesJson.map((issue) {
        final name = issue['name'] ?? '';
        final vol = issue['volume'] != null ? issue['volume']['name'] : '';
        final numero = issue['issue_number'] ?? '';
        final image = issue['image'] != null ? issue['image']['icon_url'] : '';
        final about = issue['deck'] ?? '';

        return {
          'name': name,
          'volume': vol,
          'deck': about,
          'issue_number': numero,
          'image': image,
        };
      }).toList();

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': extractedIssuesJson,
        'propertyNames': [
          "name",
          "first_appeared_in_issue",
          "publisher",
          "image"
        ],
      };
      isLoading[1] = false;
    });
  }

  void carregarPublishers() {
    columnPublishers();
    isLoading[2] = true;
    var publishersUri = Uri(
      scheme: 'https',
      host: 'comicvine.gamespot.com',
      path: 'api/publishers',
      queryParameters: {
        'limit': quantidadeItens.toString(),
        'api_key': '75504a0c3fdb9bb78d69b682d9e39fa478d71195',
        'format': 'json'
      },
    );

    http.read(publishersUri).then((jsonString) {
      var publishersJson = jsonDecode(jsonString)['results'];

      var extractedPublishersJson = publishersJson.map((publisher) {
        final name = publisher['name'] ?? '';
        final locationState = publisher['location_state'] ?? '';
        final locationCity = publisher['location_city'] ?? '';
        final image =
            publisher['image'] != null ? publisher['image']['icon_url'] : '';

        return {
          'name': name,
          'location_state': locationState,
          'location_city': locationCity,
          'image': image,
        };
      }).toList();

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': extractedPublishersJson,
        'propertyNames': ["name", "location_state", "location_city", "image"],
      };
      isLoading[2] = false;
    });
  }

  void carregarMoreItems() {
    quantidadeItens >= 1000;
    carregar(currentIndex); // Utiliza o índice da aba atual
  }

  // Função para exibir a tela de informações do personagem

  void showCharacterInfoDialog(
      BuildContext context, Map<String, dynamic> character) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Name: ${character['name'] ?? ''}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  character['image'] ?? '',
                  width: 125, // Defina a largura desejada da imagem
                  height: 125, // Defina a altura desejada da imagem
                  fit: BoxFit.contain, // Para manter a proporção da imagem
                ),
                const SizedBox(height: 8.0),
                Text('Identity: ${character['real_name'] ?? ''}'),
                const SizedBox(height: 8.0),
                Text('Race: ${character['origin'] ?? ''}'),
                const SizedBox(height: 8.0),
                Text('publisher: ${character['publisher'] ?? ''}'),
                const SizedBox(height: 8.0),
                Text(
                    'appearances: ${character['count_of_issue_appearances'] ?? ''}'),
                const SizedBox(height: 8.0),
                Text('ID: ${character['id'] ?? ''}'),
                const SizedBox(height: 8.0),
                Text('About: ${character['deck'] ?? ''}'),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

final dataService = DataService();

class Apis extends StatefulWidget {
  const Apis({super.key});

  @override
  _ApisState createState() {
    return _ApisState();
  }
}

class _ApisState extends State<Apis> {
  int currentIndex = 0; // Variável para armazenar o índice da aba atual
  List<bool> isLoading = [
    false,
    false,
    false
  ]; // Estado de carregamento de cada aba

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.red.withOpacity(0.5),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "INK-CHRONICLES 🦸‍♂️",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.blue,
        ),
        body: ValueListenableBuilder(
          valueListenable: dataService.tableStateNotifier,
          builder: (_, value, __) {
            switch (value['status']) {
              case TableStatus.idle:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/inkLogo.png',
                        width: 200.0,
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                );
              case TableStatus.loading:
                return Center(
                  child: Image.asset(
                    'assets/images/loading_animation.gif',
                    width: 400.0,
                  ),
                );
              case TableStatus.ready:
                return InfiniteScrollWidget(
                  dataObjects: value['dataObjects'],
                  propertyNames: dataService.chaves,
                  columnNames: dataService.colunas,
                  loadMoreItems: dataService.carregarMoreItems,
                  currentIndex: currentIndex, // Passa o índice da aba atual
                );
              case TableStatus.error:
                return const Text("Lascou");
            }
            return const Text("...");
          },
        ),
        bottomNavigationBar: NewNavBar(
          itemSelectedCallback: (index) {
            setState(() {
              currentIndex = index; // Atualiza o índice da aba atual
            });
            dataService.carregar(index);
          },
        ),
      ),
    );
  }
}

class NewNavBar extends HookWidget {
  final _itemNames = ['Characters', 'Issues', 'Publishers'];
  final _itemIcons = [Icons.person, Icons.book, Icons.house];

  final Function(int) itemSelectedCallback;

  NewNavBar({super.key, required this.itemSelectedCallback});

  @override
  Widget build(BuildContext context) {
    final selectedItem = useState(0);

    return BottomNavigationBar(
      items: List.generate(
        _itemNames.length,
        (index) => BottomNavigationBarItem(
          icon: Icon(_itemIcons[index]),
          label: _itemNames[index],
        ),
      ),
      currentIndex: selectedItem.value,
      onTap: (index) {
        selectedItem.value = index;
        itemSelectedCallback(index);
      },
    );
  }
}

class InfiniteScrollWidget extends StatefulWidget {
  final List<dynamic> dataObjects;
  final List<String> propertyNames;
  final List<String> columnNames;
  final VoidCallback loadMoreItems;
  int currentIndex = 0;

  InfiniteScrollWidget({super.key, 
    required this.dataObjects,
    required this.propertyNames,
    required this.columnNames,
    required this.loadMoreItems,
    required this.currentIndex,
  });

  @override
  _InfiniteScrollWidgetState createState() => _InfiniteScrollWidgetState();
}

class _InfiniteScrollWidgetState extends State<InfiniteScrollWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (!_isLoading && widget.currentIndex == currentIndex) {
        setState(() {
          _isLoading = true;
        });
        widget.loadMoreItems();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    currentIndex = widget.currentIndex;
    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        padding: const EdgeInsets.only(
          bottom: 60,
        ),
        child: Column(
          children: [
            DataTableWidget(
              jsonObjects: widget.dataObjects,
              propertyNames: widget.propertyNames,
              columnNames: widget.columnNames,
            ),
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class DataTableWidget extends StatelessWidget {
  final List<dynamic> jsonObjects;
  final List<String> propertyNames;
  final List<String> columnNames;

  const DataTableWidget({super.key, 
    required this.jsonObjects,
    required this.propertyNames,
    required this.columnNames,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final crossAxisCount = screenSize.width < 900 ? 2 : 4;
    final childAspectRatio = screenSize.width / (screenSize.height * 0.9);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: List.generate(jsonObjects.length, (index) {
        final jsonObject = jsonObjects[index];
        final imageUrl = jsonObject['image'];
        final name = jsonObject['name'];

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: GestureDetector(
            onTap: () =>
                dataService.showCharacterInfoDialog(context, jsonObject),
            child: Column(
              children: [
                Image.network(
                  imageUrl,
                  width: 100.0,
                ),
                const SizedBox(height: 4.0),
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
              ],
            ),
          ),
        );
      }),
    );
  }
}

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const Apis());
}
