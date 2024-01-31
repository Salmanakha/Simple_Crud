import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addData(String collection, Map<String, dynamic> data) async {
    await _firestore.collection(collection).add(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getData(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  Future<void> updateData(
      String collection, String documentId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(documentId).update(data);
  }

  Future<void> deleteData(String collection, String documentId) async {
    await _firestore.collection(collection).doc(documentId).delete();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _textFieldController = TextEditingController();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 91, 247, 195),
        title: const Text('Firebase CRUD Example'),
      ),
      body: StreamBuilder(
        stream: _firebaseService.getData('your_collection'),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var document = snapshot.data!.docs[index];
                return ListTile(
                  title: Text(document['your_field']),
                  // Add more UI elements as needed
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(
                            context, document.id, document['your_field']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _firebaseService.deleteData(
                            'your_collection', document.id),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 91, 247, 195),
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          
          title: const Text('Add Data'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(labelText: 'Enter data'),
          ),
        
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _firebaseService.addData('your_collection', {
                  'your_field': _textFieldController.text,
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, String documentId, String currentData) async {
    _textFieldController.text = currentData;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Data'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(labelText: 'Enter updated data'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _firebaseService
                    .updateData('your_collection', documentId, {
                  'your_field': _textFieldController.text,
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
  },
);
}
}