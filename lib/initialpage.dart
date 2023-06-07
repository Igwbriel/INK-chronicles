import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum TableStatus { idle, loading, ready, error }

class DataService {
  final ValueNotifier<Map<String, dynamic>> tableStateNotifier =
      ValueNotifier({'status': TableStatus.idle, 'dataObjects': []});

  var chaves = ["name", "style", "ibu"];
  var colunas = ["Nome", "Estilo", "IBU"];
  var quantidadeItens = 22;

  void columnTeams() {
    chaves = ["name", "first_appeared_in_issue", "publisher", "image"];
    colunas = ["Nome", "Primeira aparição", "Editora", "logo"];
  }

  void columnCharacters() {
    chaves = ["name", "origin", "publisher", "image"];
    colunas = ["Nome", "Origem", "Editora", "perfil"];
  }

  void columnPublishers() {
    chaves = ["name", "location_state", "location_city", "image"];
    colunas = ["Nome", "Estado", "Cidade", "Logo"];
  }

  void carregar(index) {
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

      var extractedCharactersJson = charactersJson
          .map((character) => {
                'name': character['name'],
                'origin': character['origin']['name'],
                'publisher': character['publisher']['name'],
                'image': character['image']['icon_url']
              })
          .toList();

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': extractedCharactersJson,
        'propertyNames': ["name", "origin", "publisher", "image"],
      };
    });
  }

  void carregarTeams() {
    columnTeams();
    var teamsUri = Uri(
        scheme: 'https',
        host: 'comicvine.gamespot.com',
        path: 'api/teams',
        queryParameters: {
          'limit': quantidadeItens.toString(),
          'api_key': '75504a0c3fdb9bb78d69b682d9e39fa478d71195',
          'format': 'json'
        });

    http.read(teamsUri).then((jsonString) {
      var teamsJson = jsonDecode(jsonString)['results'];

      var extractedTeamsJson = teamsJson
          .map((team) => {
                'name': team['name'],
                'first_appeared_in_issue': team['first_appeared_in_issue']
                    ['name'],
                'publisher': team['publisher']['name'],
                'image': team['image']['icon_url']
              })
          .toList();

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': extractedTeamsJson,
        'propertyNames': [
          "name",
          "first_appeared_in_issue",
          "publisher",
          "image"
        ]
      };
    });
  }

  void carregarPublishers() {
    columnPublishers();
    var publishersUri = Uri(
        scheme: 'https',
        host: 'comicvine.gamespot.com',
        path: 'api/publishers',
        queryParameters: {
          'limit': quantidadeItens.toString(),
          'api_key': '75504a0c3fdb9bb78d69b682d9e39fa478d71195',
          'format': 'json'
        });

    http.read(publishersUri).then((jsonString) {
      var publishersJson = jsonDecode(jsonString)['results'];

      var extractedPublishersJson = publishersJson
          .map((publisher) => {
                'name': publisher['name'],
                'location_state': publisher['location_state'],
                'location_city': publisher['location_city'],
                'image': publisher['image']['icon_url']
              })
          .toList();

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': extractedPublishersJson,
        'propertyNames': ["name", "location_state", "location_city", "image"]
      };
    });
  }
}

final dataService = DataService();

class Apis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black.withOpacity(0.5),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(         
          title: const Text("INK-CHRONICLES"),
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
                return SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: 60,
                    ),
                    child: DataTableWidget(
                      jsonObjects: value['dataObjects'],
                      propertyNames: dataService.chaves,
                      columnNames: dataService.colunas,
                    ),
                  ),
                );
              case TableStatus.error:
                return Text("Lascou");
            }
            return Text("...");
          },
        ),
        bottomNavigationBar:
            NewNavBar(itemSelectedCallback: dataService.carregar),
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
    return DataTable(
      columns: columnNames
          .map(
            (name) => DataColumn(
              label: Text(name),
            ),
          )
          .toList(),
      rows: jsonObjects
          .map(
            (jsonObject) => DataRow(
              cells: propertyNames
                  .map(
                    (property) => DataCell(
                      property == 'image'
                          ? Image.network(jsonObject[property])
                          : Text(jsonObject[property].toString()),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}

void main() {
  
  runApp(Apis());
}
