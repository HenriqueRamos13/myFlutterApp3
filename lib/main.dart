import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amber)))),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double _dolar;
  double _euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChange(String text) {
    double real = double.parse(text);
    dolarController.text = (real / _dolar).toStringAsFixed(2);
    euroController.text = (real / _euro).toStringAsFixed(2);
  }

  void _dolarChange(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this._dolar).toStringAsFixed(2);
    euroController.text = (dolar * this._dolar / _euro).toStringAsFixed(2);
  }

  void _euroChange(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this._euro).toStringAsFixed(2);
    dolarController.text = (euro * this._euro / this._dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            title: Text("\$ Conversor \$"),
            backgroundColor: Colors.amber,
            centerTitle: true),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar os dados.",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  _dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  _euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                      child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                        ),
                        Divider(),
                        buildTextField(
                            "Reais", "R\$", realController, _realChange),
                        Divider(),
                        buildTextField(
                            "Dolar", "\$", dolarController, _dolarChange),
                        Divider(),
                        buildTextField(
                            "Euro", "EUR", euroController, _euroChange),
                      ],
                    ),
                  ));
                }
            }
          },
        ));
  }
}

Widget buildTextField(String text, String pre, TextEditingController controller,
    Function functionEditing) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: text,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: pre,
        prefixStyle: TextStyle(color: Colors.amber, fontSize: 25.0)),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: functionEditing,
    keyboardType: TextInputType.number,
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
