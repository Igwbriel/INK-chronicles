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
  var quantidadeItens = '0';

  void columnCervejas() {
    chaves = ["name", "style", "ibu"];
    colunas = ["Nome", "Estilo", "IBU"];
  }

  void columnUsers() {
    chaves = ["first_name", "last_name", "email"];
    colunas = ["Nome", "Sobrenome", "E-mail"];
  }

  void columnCafes() {
    chaves = ["blend_name", "origin", "intensifier"];
    colunas = ["Nome da mistura", "Origem", "Intensidade"];
  }

  void columnNacoes() {
    chaves = ["nationality", "capital", "language"];
    colunas = ["Nacionalidade", "Capital", "Linguagem"];
  }

  void carregar(index) {
    final funcoes = [
      carregarCafes,
      carregarCervejas,
      carregarNacoes,
      carregarUsers
    ];
    tableStateNotifier.value = {
      'status': TableStatus.loading,
      'dataObjects': [],
      'columnNames': [],
    };
    funcoes[index]();
  }

  void carregarCafes() {
    columnCafes();
    var coffeesUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: 'api/coffee/random_coffee',
        queryParameters: {'size': quantidadeItens});

    http.read(coffeesUri).then((jsonString) {
      var coffeesJson = jsonDecode(jsonString);

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': coffeesJson,
        'propertyNames': ["blend_name", "origin", "intensifier"]
      };
    });
  }

  void carregarUsers() {
    columnUsers();
    var usersUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: '/api/v2/users',
        queryParameters: {'size': quantidadeItens});

    http.read(usersUri).then((jsonString) {
      var usersJson = jsonDecode(jsonString);

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': usersJson,
        'propertyNames': ["first_name", "last_name", "email"]
      };
    });
  }

  void carregarNacoes() {
    columnNacoes();
    var nationsUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: 'api/nation/random_nation',
        queryParameters: {'size': quantidadeItens});

    http.read(nationsUri).then((jsonString) {
      var nationsJson = jsonDecode(jsonString);

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': nationsJson,
        'propertyNames': ["nationality", "capital", "language"]
      };
    });
  }

  void carregarCervejas() {
    columnCervejas();
    var beersUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: 'api/beer/random_beer',
        queryParameters: {'size': quantidadeItens});

    http.read(beersUri).then((jsonString) {
      var beersJson = jsonDecode(jsonString);

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': beersJson,
        'propertyNames': ["name", "style", "ibu"]
      };
    });
  }
}

final dataService = DataService();

class Apis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Colors.purple,
            unselectedItemColor: Colors.purple.withOpacity(0.5),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Receita: 7/8"),
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
            padding: EdgeInsets.only(bottom: 60), // Adicionar espaço para os botões
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
          bottomSheet: Container(
            height: 60,
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  dataService.quantidadeItens = '5';
                },
                child: Text("5"),
              ),
              ElevatedButton(
                onPressed: () {
                  dataService.quantidadeItens = '10';
                },
                child: Text("10"),
              ),
              ElevatedButton(
                onPressed: () {
                  dataService.quantidadeItens = '15';
                },
                child: Text("15"),
              ),
            ],
          ),
          ),
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
            label: "Cafés",
            icon: Icon(Icons.coffee_outlined),
          ),
          BottomNavigationBarItem(
              label: "Cervejas", icon: Icon(Icons.local_drink_outlined)),
          BottomNavigationBarItem(
              label: "Nações", icon: Icon(Icons.flag_outlined)),
          BottomNavigationBarItem(
              label: "Usuários", icon: Icon(Icons.local_phone_outlined))
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
    this.propertyNames = const ["name", "style", "ibu"],
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
                    (propName) => DataCell(Text(obj[propName])),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
