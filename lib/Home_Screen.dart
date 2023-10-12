import 'package:flutter/material.dart';
import 'package:traduction_flutter/Play_Screen.dart';
import 'package:traduction_flutter/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;

  void _refreshData() async {
    final data = await SQLHelper.getData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  final TextEditingController _frenchController = TextEditingController();
  final TextEditingController _englishController = TextEditingController();

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _frenchController.text = existingData['french'];
      _englishController.text = existingData['english'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _frenchController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Francais",
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _englishController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "English",
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    print(_allData);
                    await _addData();
                  }
                  if (id != null) {
                    await _updateData(id);
                  }

                  _frenchController.text = "";
                  _englishController.text = "";

                  Navigator.of(context).pop();
                  print("Data added");
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Ajouter" : "Modifier",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addData() async {
    await SQLHelper.createData(_frenchController.text, _englishController.text);
    _refreshData();
  }

  Future<void> _updateData(int id) async {
    await SQLHelper.updateData(
        id, _frenchController.text, _englishController.text);
    _refreshData();
  }

  void _deleteData(int id) async {
    await SQLHelper.delateData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Traduction supprimmé'),
      backgroundColor: Colors.redAccent,
    ));
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text("Liste des mots / Words list"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PlayScreen()));
              },
              icon: Icon(Icons.search)),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allData.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      _allData[index]['french'],
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    _allData[index]['english'],
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            showBottomSheet(_allData[index]['id']);
                          },
                          icon: Icon(Icons.edit, color: Colors.amber)),
                      IconButton(
                          onPressed: () {
                            _deleteData(_allData[index]['id']);
                          },
                          icon: Icon(Icons.delete_forever_outlined,
                              color: Colors.redAccent))
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: Icon(Icons.addchart_rounded),
      ),
    );
  }
}
