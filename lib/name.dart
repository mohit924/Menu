import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menu_scan_web/QRGeneratorPage.dart';

class NamePage extends StatefulWidget {
  final String idFromQR;

  NamePage({required this.idFromQR});

  @override
  _NamePageState createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final TextEditingController _nameController = TextEditingController();
  final CollectionReference namesCollection = FirebaseFirestore.instance
      .collection('names');

  void _addName() async {
    String name = _nameController.text.trim();
    if (name.isEmpty) return;

    try {
      await namesCollection.add({'name': name, 'timestamp': DateTime.now()});
      _nameController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Name added successfully!')));
    } catch (e) {
      print('Firestore error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error adding name: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Your Name'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code, color: Colors.black),
            tooltip: 'Generate QR',
            onPressed: () {
              // Navigate to QRManagerPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRManagerPage()),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You came from QR ID: ${widget.idFromQR}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _addName, child: Text('Submit')),
            SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: namesCollection
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading names: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(child: Text('No names added yet.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Text('${index + 1}'),
                        title: Text(docs[index]['name']),
                        subtitle: Text(
                          'ID: ${widget.idFromQR} | '
                          '${(docs[index]['timestamp'] as Timestamp).toDate().toLocal()}',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
