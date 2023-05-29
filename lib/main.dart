import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataService {
  final ValueNotifier<List> tableStateNotifier = new ValueNotifier([]);
  void carregar(index) {
    var res = null;
    print('carregar #1 - antes de carregarCervejas');
    if (index == 1) res = carregarCervejas();
    print('carregar #2 - carregarCervejas retornou $res');
    //print('carregar #1 - antes de carregarCafes');
    // if (index == 2) res = carregarCafes();
    //print('carregar #2 - carregarCafes retornou $res');
  }

  Future<void> carregarCervejas() async {
    var beersUri = Uri(
        scheme: 'https',
        host: 'http://comicvine.gamespot.com/api',
        path: 'api/beer/random_beer',
        queryParameters: {'size': '5'});
    print('carregarCervejas #1 - antes do await');
    var jsonString = await http.read(beersUri);
    print('carregarCervejas #2 - depois do await');
    var beersJson = jsonDecode(jsonString);
    print(beersJson);
    var oneJson = beersJson[0] as Map<String, dynamic>;
    var allProps = oneJson.keys.toList();
    print(oneJson.runtimeType);
    print(beersJson);
    print(allProps);
    tableStateNotifier.value = beersJson;
  }

  Future<void> carregarCafes() async {
    var coffeeUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: '/api/coffee/random_coffee',
        queryParameters: {'size': '5'});
    print('carregarCafes #1 - antes do await');
    var jsonString = await http.read(coffeeUri);
    print('carregarCafes #2 - depois do await');
    var coffeesJson = jsonDecode(jsonString as String);
    tableStateNotifier.value = coffeesJson;
  }

  Future<void> carregarNacoes() async {
    var nationUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: '/api/nation/random_nation',
        queryParameters: {'size': '5'});
    print('carregarNacoes #1 - antes do await');
    var jsonString = await http.read(nationUri);
    print('carregarNacoes #2 - depois do await');
    var nationsJson = jsonDecode(jsonString as String);
    tableStateNotifier.value = nationsJson;
  }
}

final dataService = DataService();
void main() {
  MyApp app = MyApp();
  runApp(app);
}

class Homepage extends

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Dicas"),
          ),
          body: ValueListenableBuilder(
              valueListenable: dataService.tableStateNotifier,
              builder: (_, value, __) {
                return DataTableWidget(
                    jsonObjects: value,
                    propertyNames: ["name", "style", "ibu"],
                    columnNames: ["Nome", "Estilo", "IBU"]);
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
            label: "Cafés",
            icon: Icon(Icons.coffee_outlined),
          ),
          BottomNavigationBarItem(
              label: "Cervejas", icon: Icon(Icons.local_drink_outlined)),
          BottomNavigationBarItem(
              label: "Nações", icon: Icon(Icons.flag_outlined))
        ]);
  }
}

class DataTableWidget extends StatelessWidget {
  final List jsonObjects;
  final List<String> columnNames;
  final List<String> propertyNames;
  DataTableWidget(
      {this.jsonObjects = const [],
      this.columnNames = const ["Nome", "Estilo", "IBU"],
      this.propertyNames = const ["name", "style", "ibu"]});
  @override
  Widget build(BuildContext context) {
    return DataTable(
        columns: columnNames
            .map((name) => DataColumn(
                label: Expanded(
                    child: Text(name,
                        style: TextStyle(fontStyle: FontStyle.italic)))))
            .toList(),
        rows: jsonObjects
            .map((obj) => DataRow(
                cells: propertyNames
                    .map((propName) => DataCell(Text(obj[propName])))
                    .toList()))
            .toList());
  }
}
