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
  var quantidadeItens = 21;

  void columnCharacters() {
    currentIndex = 0;
    chaves = ["name", "origin", "publisher", "image"];
    colunas = ["Nome", "Origem", "Editora", "perfil"];
  }

  void columnTeams() {
    currentIndex = 1;
    chaves = ["name", "first_appeared_in_issue", "publisher", "image"];
    colunas = ["Nome", "Primeira aparição", "Editora", "logo"];
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
      carregarTeams,
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

        return {
          'name': name,
          'origin': origin,
          'publisher': publisher,
          'image': image,
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

  void carregarTeams() {
    columnTeams();
    isLoading[1] = true;
    var teamsUri = Uri(
      scheme: 'https',
      host: 'comicvine.gamespot.com',
      path: 'api/teams',
      queryParameters: {
        'limit': quantidadeItens.toString(),
        'api_key': '75504a0c3fdb9bb78d69b682d9e39fa478d71195',
        'format': 'json'
      },
    );

    http.read(teamsUri).then((jsonString) {
      var teamsJson = jsonDecode(jsonString)['results'];

      var extractedTeamsJson = teamsJson.map((team) {
        final name = team['name'] ?? '';
        final firstAppearedInIssue = team['first_appeared_in_issue'] != null
            ? team['first_appeared_in_issue']['name']
            : '';
        final publisher =
            team['publisher'] != null ? team['publisher']['name'] : '';
        final image = team['image'] != null ? team['image']['icon_url'] : '';

        return {
          'name': name,
          'first_appeared_in_issue': firstAppearedInIssue,
          'publisher': publisher,
          'image': image,
        };
      }).toList();

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': extractedTeamsJson,
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
    quantidadeItens += 22;
    carregar(chaves.indexWhere((element) => element != null));
  }
}

final dataService = DataService();

class Apis extends StatefulWidget {
  @override
  _ApisState createState() => _ApisState();
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
            "INK-CHRONICLES",
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
                      SizedBox(height: 16.0),
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
                return Text("Lascou");
            }
            return Text("...");
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
  final _itemNames = ['Personagens', 'Times', 'Editoras'];
  final _itemIcons = [Icons.person, Icons.group, Icons.house];

  final Function(int) itemSelectedCallback;

  NewNavBar({required this.itemSelectedCallback});

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

  InfiniteScrollWidget({
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
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
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
        padding: EdgeInsets.only(
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
                ? Padding(
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

  DataTableWidget({
    required this.jsonObjects,
    required this.propertyNames,
    required this.columnNames,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.7, // Ajuste o valor conforme necessário
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: List.generate(jsonObjects.length, (index) {
        final jsonObject = jsonObjects[index];
        final imageUrl = jsonObject['image'];
        final name = jsonObject['name'];
        String additionalInfo = '';

        if (propertyNames.contains('origin')) {
          final origin = jsonObject['origin'];
          if (origin != null) {
            additionalInfo = origin;
          }
        } else if (propertyNames.contains('first_appeared_in_issue')) {
          final firstAppearance = jsonObject['first_appeared_in_issue'];
          if (firstAppearance != null) {
            additionalInfo = firstAppearance;
          }
        } else if (propertyNames.contains('location_state')) {
          final locationState = jsonObject['location_state'];
          final locationCity = jsonObject['location_city'];
          if (locationState != null && locationCity != null) {
            additionalInfo = '$locationCity, $locationState';
          }
        }

        return Container(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            children: [
              Image.network(
                imageUrl,
                width: 100.0,
              ),
              SizedBox(height: 4.0),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                additionalInfo,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
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

  runApp(Apis());
}
