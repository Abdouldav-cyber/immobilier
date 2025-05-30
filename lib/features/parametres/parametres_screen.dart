import 'package:flutter/material.dart';
import 'package:gestion_immo/features/parametres/commodite_maisons_screen.dart';
import 'package:gestion_immo/features/parametres/commodites_screen.dart';
import 'package:gestion_immo/features/parametres/commune_screen.dart';
import 'package:gestion_immo/features/parametres/type_documents_screen.dart';
//import 'package:gestion_immo/features/parametres/type_document_screen.dart';

class ParametresScreen extends StatelessWidget {
  const ParametresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Commodités'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CommoditesScreen())),
          ),
          ListTile(
            title: const Text('Commodités Maisons'),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CommoditeMaisonsScreen())),
          ),
          ListTile(
            title: const Text('Communes'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CommuneScreen())),
          ),
          ListTile(
            title: const Text('Types de Documents'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TypeDocumentsScreen())),
          ),
          // ListTile(
          //   title: const Text('Type de Document'),
          //   onTap: () => Navigator.push(context,
          //       MaterialPageRoute(builder: (_) => const TypeDocumentScreen())),
          // ),
        ],
      ),
    );
  }
}
