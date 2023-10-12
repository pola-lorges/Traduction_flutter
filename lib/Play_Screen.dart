import 'dart:math';

import 'package:flutter/material.dart';
import 'package:traduction_flutter/db_helper.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  List<Map<String, dynamic>> _allData = [];

  void _refreshData() async {
    final data = await SQLHelper.getData();
    setState(() {
      _allData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  final TextEditingController _frenchController = TextEditingController();
  final TextEditingController _traductionController = TextEditingController();
  final TextEditingController _englishController = TextEditingController();
  late String temp = " ";

  void newWord() async {
    
    _traductionController.clear();
    _englishController.clear();
    int id = Random().nextInt(_allData.length + 1);
    print(id);
    var existingData = _allData[id];
    while (existingData.isEmpty) {
      id = Random().nextInt(_allData.length);
      print(id);
      existingData = _allData.firstWhere((element) => element['id'] == id);
    }
    _frenchController.text = existingData['french'];
    temp = existingData['english'];
  }

  void tryTranslate() async {
    if (_traductionController.text == temp) {
      print(true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Traduction Réussie'),
        backgroundColor: Colors.green,
      ));
    } else {
      print(false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Traduction Echouée'),
        backgroundColor: Colors.redAccent,
      ));
    }
    _englishController.text = temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text("Essaie de traduire"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  newWord();
                  print("New Word");
                },
                child: const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    "Nouveau mot",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _frenchController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Francais",
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _traductionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Essaie de traduire",
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  print("try translate");
                  tryTranslate();
                },
                child: const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    "Traduire",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _englishController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Traduction",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
