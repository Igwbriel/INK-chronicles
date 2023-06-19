// ignore_for_file: must_be_immutable, non_constant_identifier_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum TableStatus { idle, loading, ready, error }

class DataService {
  List<bool> isLoading = [false, false, false];
  int currentIndex = 0;
  final ValueNotifier<Map<String, dynamic>> tableStateNotifier =
      ValueNotifier({'status': TableStatus.idle, 'dataObjects': []});
  List<Map<String, dynamic>> currentDataObjects = [];
  var chaves = ["name", "style", "ibu"];
  var colunas = ["Nome", "Estilo", "IBU"];
  var quantidadeItens = 100;

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

  void carregar(index, {int page = 1}) {
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
    funcoes[index](page);
  }

  void carregarCharacters(int page) {
    columnCharacters();
    isLoading[0] = true;
    var charactersUri = Uri(
      scheme: 'https',
      host: 'comicvine.gamespot.com',
      path: 'api/characters',
      queryParameters: {
        'offset': ((page - 1) * quantidadeItens).toString(),
        'limit': quantidadeItens.toString(),
        'api_key': '75504a0c3fdb9bb78d69b682d9e39fa478d71195',
        'format': 'json'
      },
    );

    http.read(charactersUri).then((jsonString) {
      var charactersJson = jsonDecode(jsonString)['results'];

      var extractedCharactersJson =
          charactersJson.map<Map<String, dynamic>>((character) {
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
          'count_of_issue_appearances': contagem,
          'deck': resumo,
          'ID': ID,
        };
      }).toList();

      currentDataObjects.addAll(extractedCharactersJson);
      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': currentDataObjects,
        'propertyNames': ["name", "origin", "publisher", "image"],
      };

      isLoading[0] = false;
    });
  }

  void carregarIssues(int page) {
    columnIssues();
    isLoading[1] = true;
    var issuesUri = Uri(
      scheme: 'https',
      host: 'comicvine.gamespot.com',
      path: 'api/issues',
      queryParameters: {
        'offset': ((page - 1) * quantidadeItens).toString(),
        'limit': quantidadeItens.toString(),
        'api_key': '75504a0c3fdb9bb78d69b682d9e39fa478d71195',
        'format': 'json'
      },
    );

    http.read(issuesUri).then((jsonString) {
      var issuesJson = jsonDecode(jsonString)['results'];

      var extractedIssuesJson = issuesJson.map<Map<String, dynamic>>((issue) {
        final name = issue['name'] ?? '';
        final volume = issue['volume'] != null ? issue['volume']['name'] : '';
        final deck = issue['deck'] ?? '';
        final issueNumber = issue['issue_number'] ?? '';
        final image = issue['image'] != null ? issue['image']['icon_url'] : '';

        return {
          'name': name,
          'volume': volume,
          'deck': deck,
          'issue_number': issueNumber,
          'image': image,
        };
      }).toList();

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': extractedIssuesJson,
        'propertyNames': ["name", "volume", "deck", "issue_number", "image"],
      };

      isLoading[1] = false;
    });
  }

  void carregarPublishers(int page) {
    columnPublishers();
    isLoading[2] = true;
    var publishersUri = Uri(
      scheme: 'https',
      host: 'comicvine.gamespot.com',
      path: 'api/publishers',
      queryParameters: {
        'offset': ((page - 1) * quantidadeItens).toString(),
        'limit': quantidadeItens.toString(),
        'api_key': '75504a0c3fdb9bb78d69b682d9e39fa478d71195',
        'format': 'json'
      },
    );

    http.read(publishersUri).then((jsonString) {
      var publishersJson = jsonDecode(jsonString)['results'];

      var extractedPublishersJson = publishersJson.map<Map<String, dynamic>>((publisher) {
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

  void showCharacterInfoDialog(BuildContext context, jsonObject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(jsonObject['name']),
          content: Column(
            children: [
              Image.network(jsonObject['image']),
              const SizedBox(height: 8.0),
              Text('Identity: ${jsonObject['real_name']}'),
              const SizedBox(height: 8.0),
              Text('Origin: ${jsonObject['origin']}'),
              const SizedBox(height: 8.0),
              Text('Publisher: ${jsonObject['publisher']}'),
              const SizedBox(height: 8.0),
              Text('Appearances: ${jsonObject['count_of_issue_appearances']}'),
              const SizedBox(height: 8.0),
              Text('About: ${jsonObject['deck']}'),
              const SizedBox(height: 8.0),
              // Adicione mais informações que desejar
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showIssueInfoDialog(BuildContext context, jsonObject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(jsonObject['name']),
          content: Column(
            children: [
              Image.network(jsonObject['image']),
              const SizedBox(height: 8.0),
              Text('Name: ${jsonObject['name']}'),
              const SizedBox(height: 8.0),
              Text('Volume: ${jsonObject['volume']}'),
              const SizedBox(height: 8.0),
              Text('Number: ${jsonObject['issue_number']}'),
              const SizedBox(height: 8.0),
              // Adicione mais informações que desejar
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showPublisherInfoDialog(BuildContext context, jsonObject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(jsonObject['name']),
          content: Column(
            children: [
              Image.network(jsonObject['image']),
              const SizedBox(height: 8.0),
              Text('Name: ${jsonObject['name']}'),
              const SizedBox(height: 8.0),
              Text('State: ${jsonObject['location_state']}'),
              const SizedBox(height: 8.0),
              Text('City: ${jsonObject['location_city']}'),
              const SizedBox(height: 8.0),
              // Add more information as desired
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

final dataService = DataService();

class Apis extends StatefulWidget {
  const Apis({Key? key}) : super(key: key);

  @override
  _ApisState createState() => _ApisState();
}

class _ApisState extends State<Apis> {
  final DataService dataService = DataService();


  @override
  void initState() {
    super.initState();
    dataService.carregar(dataService.currentIndex);
  }

  void _onTabChanged(int index) {
    if (dataService.currentIndex!= index) {
      dataService.currentIndex = index;
      dataService.carregar(dataService.currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "INK-CHRONICLES 🦸‍♂️",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('INK-CHRONICLES 🦸‍♂️'),
            bottom: TabBar(
              tabs: const [
                Tab(
                  icon: Icon(Icons.person),
                  text: 'Characters',
                ),
                Tab(
                  icon: Icon(Icons.article),
                  text: 'Issues',
                ),
                Tab(
                  icon: Icon(Icons.business),
                  text: 'Publishers',
                ),
              ],
              onTap: _onTabChanged,
            ),
          ),
          body: TabBarView(
            children: [
              InfiniteScrollWidget(dataService: dataService, index: 0),
              InfiniteScrollWidget(dataService: dataService, index: 1),
              InfiniteScrollWidget(dataService: dataService, index: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class InfiniteScrollWidget extends HookWidget {
  final DataService dataService;
  final int index;

  InfiniteScrollWidget({Key? key, required this.dataService, required this.index})
      : super(key: key);

  final _scrollController = ScrollController();
  int page = 1;
  final int _previousScrollPosition = 0;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
          page++;
          if (dataService.currentIndex == 0) {
            dataService.carregarCharacters(page);
          } else if (dataService.currentIndex == 1) {
            dataService.carregarIssues(page);
          } else if (dataService.currentIndex == 2) {
            dataService.carregarPublishers(page);
          }
        }
      });

      return () {
        _scrollController.removeListener(() {});
      };
    }, []);

    final tableState = useValueListenable(dataService.tableStateNotifier);
    final tableStatus = tableState['status'];
    final dataObjects = tableState['dataObjects'];
    final propertyNames = tableState['propertyNames'];

    if (tableStatus == TableStatus.error) {
      return const Center(
        child: Text('An error occurred while loading the data.'),
      );
    }

    if (tableStatus == TableStatus.loading && dataObjects.isEmpty) {
      return Center(
        child: Image.asset(
          'assets/images/loading_animation.gif',
          width: 400.0, // Customize the color if desired
        ),
      );
    }

    if (tableStatus == TableStatus.idle && dataObjects.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            page = 1;
            if (dataService.currentIndex == 0) {
              dataService.carregarCharacters(page);
            } else if (dataService.currentIndex == 1) {
              dataService.carregarIssues(page);
            } else if (dataService.currentIndex == 2) {
              dataService.carregarPublishers(page);
            }
          },
          child: const Text('Load Data'),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_previousScrollPosition > 0) {
        _scrollController.jumpTo(_previousScrollPosition as double);
      }
    });
    
    return ListView.builder(
      controller: _scrollController,
      itemCount: dataObjects.length + 1,
      itemBuilder: (context, index) {
        if (index == dataObjects.length) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        final dataObject = dataObjects[index];
        return InkWell(
          onTap: () {
            if (dataService.currentIndex == 0) {
              dataService.showCharacterInfoDialog(context, dataObject);
            } else
            if (dataService.currentIndex == 1) {
              dataService.showIssueInfoDialog(context, dataObject);
            } else
            if (dataService.currentIndex == 2) {
              dataService.showPublisherInfoDialog(context, dataObject);
            }
          },
          child: ListTile(
            leading: Image.network(
              dataObject['image'],
              height: 40,
              width: 40,
            ),
            title: Text(dataObject[propertyNames[0]]),
            subtitle: Text(dataObject[propertyNames[1]]),
          ),
        );
      },
    );
  }
}

class DataTableWidget extends StatelessWidget {
  final List<dynamic> jsonObjects;
  final List<String> propertyNames;
  final List<String> columnNames;
  final int currentIndex;

  const DataTableWidget({
    Key? key,
    required this.jsonObjects,
    required this.propertyNames,
    required this.columnNames,
    required this.currentIndex,
  }) : super(key: key);

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
            onTap: () {
              if (currentIndex == 0) {
                dataService.showCharacterInfoDialog(context, jsonObject);
              }
              if (currentIndex == 1) {
                dataService.showIssueInfoDialog(context, jsonObject);
              }
              if (currentIndex == 2) {
                dataService.showPublisherInfoDialog(context, jsonObject);
              }
            },
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
