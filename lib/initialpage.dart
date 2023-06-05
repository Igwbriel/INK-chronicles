import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:ink_chronicles/matrial/material_color.dart';

enum TableStatus { idle, loading, ready, error }

class DataService {
  final ValueNotifier<Map<String, dynamic>> tableStateNotifier =
      ValueNotifier({'status': TableStatus.idle, 'dataObjects': []});

  var chaves = ["name", "style", "ibu"];
  var colunas = ["Nome", "Estilo", "IBU"];
  var quantidadeItens = 22;

  void columnTeams() {
    chaves = ["name", "first_appeared_in_issue", "publisher"];
    colunas = ["Nome", "Primeira aparição", "Editora"];
  }

  void columnCharacters() {
    chaves = ["name", "origin", "publisher", "image"];
    colunas = ["Nome", "Origem", "Editora", "perfil"];
  }

  void columnPublishers() {
    chaves = ["name", "location_state", "location_city"];
    colunas = ["Nome", "Estado", "Cidade"];
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
              })
          .toList();

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': extractedTeamsJson,
        'propertyNames': ["name", "first_appeared_in_issue", "publisher"]
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
              })
          .toList();

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': extractedPublishersJson,
        'propertyNames': ["name", "location_state", "location_city"]
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
          primarySwatch: black,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: black,
            unselectedItemColor: black.withOpacity(0.5),
          ),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text("INK-CHRONICLES"),
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
                          SizedBox(
                            height: 16.0,
                          ),
                          Text(
                            "Selecione um dos botões roxos para receber a quantiade de dados, e abaixo",
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "um botão com o conteúdo de uma API correspondente!",
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  case TableStatus.loading:
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  case TableStatus.ready:
                    return SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only(
                            bottom: 60), // Adicionar espaço para os botões
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
              }),
          bottomNavigationBar:
              NewNavBar(itemSelectedCallback: dataService.carregar),
          
        ));
  }
}

class NewNavBar extends HookWidget {
  final _itemSelectedCallback;

  NewNavBar({itemSelectedCallback})
      : _itemSelectedCallback = itemSelectedCallback ?? (int) {}

  @override
  Widget build(BuildContext context) {
    var state = useState(1);

    return BottomNavigationBar(
        onTap: (index) {
          state.value = index;

          _itemSelectedCallback(index);
        },
        currentIndex: state.value,
        items: const [
          BottomNavigationBarItem(
            label: "Personagens",
            icon: Icon(Icons.person),
          ),
          BottomNavigationBarItem(label: "Times", icon: Icon(Icons.group)),
          BottomNavigationBarItem(label: "Editoras", icon: Icon(Icons.house)),
        ]);
  }
}

class DataTableWidget extends StatelessWidget {
  final List jsonObjects;
  final List<String> columnNames;
  final List<String> propertyNames;

  DataTableWidget({
    this.jsonObjects = const [],
    this.columnNames = const [],
    this.propertyNames = const ["name", "origin", "publisher", "image"],
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: columnNames
          .map(
            (name) => DataColumn(
              label: Expanded(
                child: Text(
                  name,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          )
          .toList(),
      rows: jsonObjects
          .map(
            (obj) => DataRow(
              cells: propertyNames
                  .map(
                    (propName) => propName == 'image'
                        ? DataCell(
                            Image.network(obj[propName].toString()),
                          )
                        : DataCell(Text(obj[propName].toString())),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
