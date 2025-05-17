import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/data/services/document_service.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final DocumentService _documentService = DocumentService();
  List<dynamic> documents = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    try {
      final data = await _documentService.getDocuments();
      setState(() {
        documents = data;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
      ),
      body: error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MdiIcons.fileDocument, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Erreur lors du chargement : $error',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            )
          : documents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(MdiIcons.fileDocument, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucun document trouvé',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    return ListTile(
                      title: Text(document['nom'] ?? 'Document sans nom'),
                      subtitle: Text('Type: ${document['type'] ?? 'N/A'}'),
                      onTap: () {
                        print('Clic sur document ${document['nom']}');
                      },
                    );
                  },
                ),
    );
  }
}
