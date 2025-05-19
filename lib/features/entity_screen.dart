import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/data/services/base_service.dart';

abstract class EntityScreen extends StatefulWidget {
  final String title;
  final BaseService service;
  final String entityName;

  const EntityScreen(
      {super.key,
      required this.title,
      required this.service,
      required this.entityName});

  @override
  State<EntityScreen> createState();
}

class EntityScreenState<T extends EntityScreen> extends State<T> {
  List<dynamic> items = [];
  String? error;
  bool isLoading = true;
  final Map<String, TextEditingController> _controllers = {};

  dynamic _editingItem;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchItems();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _initializeControllers() {
    switch (widget.entityName.toLowerCase()) {
      case 'maison':
        _controllers['adresse'] = TextEditingController();
        _controllers['superficie'] = TextEditingController();
        break;
      case 'agence':
        _controllers['nom'] = TextEditingController();
        break;
      case 'location':
        _controllers['dateDebut'] = TextEditingController();
        _controllers['dateFin'] = TextEditingController();
        break;
      case 'paiement':
        _controllers['montant'] = TextEditingController();
        _controllers['datePaiement'] = TextEditingController();
        break;
      case 'penalite':
        _controllers['montant'] = TextEditingController();
        _controllers['motif'] = TextEditingController();
        break;
      case 'document':
        _controllers['numeroDocument'] = TextEditingController();
        _controllers['dateEtabli'] = TextEditingController();
        break;
      case 'commune':
        _controllers['nom'] = TextEditingController();
        break;
      case 'commodite':
        _controllers['nom'] = TextEditingController();
        break;
      case 'commodite-maison':
        _controllers['maisonId'] = TextEditingController();
        _controllers['commoditeId'] = TextEditingController();
        break;
      case 'photo':
        _controllers['url'] = TextEditingController();
        break;
    }
  }

  Future<void> _fetchItems() async {
    setState(() => isLoading = true);
    try {
      final data = await widget.service.getAll();
      setState(() {
        items = data;
        error = null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _showAddEditDialog({dynamic item}) {
    if (item != null) {
      _editingItem = item;
      _controllers.forEach((key, controller) {
        controller.text = item[key]?.toString() ?? '';
      });
    } else {
      _editingItem = null;
      _controllers.forEach((_, controller) => controller.clear());
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null
            ? 'Ajouter un ${widget.entityName}'
            : 'Modifier un ${widget.entityName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _controllers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: entry.key,
                    border: const OutlineInputBorder(),
                    errorText: _validateField(entry.key)
                        ? 'Ce champ est requis'
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_controllers.values
                  .any((controller) => controller.text.isEmpty)) {
                setState(
                    () {}); // Rafraîchir pour afficher les erreurs de validation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Veuillez remplir tous les champs obligatoires')),
                );
                return;
              }

              final data = _controllers
                  .map((key, controller) => MapEntry(key, controller.text));
              if (_editingItem != null) {
                final confirm = await _showConfirmationDialog(
                  title: 'Confirmer la modification',
                  content: 'Êtes-vous sûr de vouloir modifier cet élément ?',
                );
                if (!confirm) return;
              }
              try {
                if (_editingItem == null) {
                  await widget.service.create(data);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${widget.entityName} ajouté avec succès')),
                  );
                } else {
                  await widget.service.update(_editingItem['id'], data);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${widget.entityName} modifié avec succès')),
                  );
                }
                Navigator.pop(context);
                _fetchItems();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            child: Text(item == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  bool _validateField(String field) {
    return _controllers[field]?.text.isEmpty ?? true;
  }

  Future<bool> _showConfirmationDialog(
      {required String title, required String content}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmer'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showDetailsDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.entityName} #${item['id']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: item.entries.map<Widget>((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${entry.key}: ${entry.value ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddEditDialog(item: item);
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(int id) async {
    final confirm = await _showConfirmationDialog(
      title: 'Confirmer la suppression',
      content: 'Êtes-vous sûr de vouloir supprimer cet élément ?',
    );
    if (!confirm) return;

    try {
      await widget.service.delete(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.entityName} supprimé avec succès')),
      );
      _fetchItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur suppression: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: _getEntityColor(widget.entityName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchItems,
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Ajouter un ${widget.entityName}',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F0E7), Color(0xFFEDE1D2), Color(0xFFD4C4B1)],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.brown))
            : error != null
                ? Center(
                    child: Text('Erreur: $error',
                        style: const TextStyle(color: Colors.red)))
                : items.isEmpty
                    ? Center(
                        child: Text('Aucun ${widget.entityName} trouvé',
                            style: const TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            elevation: 6,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            color: Colors.white.withOpacity(0.9),
                            child: ListTile(
                              onTap: () => _showDetailsDialog(item),
                              leading: Icon(_getEntityIcon(widget.entityName),
                                  color: _getEntityColor(widget.entityName)),
                              title: Text(
                                '${widget.entityName} #${item['id']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getEntityColor(widget.entityName)),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _controllers.keys.map((key) {
                                  return Text('$key: ${item[key] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 14));
                                }).toList(),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _showAddEditDialog(item: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteItem(item['id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Color _getEntityColor(String entityName) {
    switch (entityName.toLowerCase()) {
      case 'maison':
        return Colors.amber;
      case 'agence':
        return Colors.orange;
      case 'location':
        return Colors.green;
      case 'paiement':
        return Colors.teal;
      case 'penalite':
        return Colors.red;
      case 'document':
        return Colors.indigo;
      case 'commune':
        return Colors.purple;
      case 'commodite':
        return Colors.blue;
      case 'commodite-maison':
        return Colors.cyan;
      case 'photo':
        return Colors.deepPurple;
      default:
        return Colors.brown;
    }
  }

  IconData _getEntityIcon(String entityName) {
    switch (entityName.toLowerCase()) {
      case 'maison':
        return MdiIcons.home;
      case 'agence':
        return MdiIcons.officeBuilding;
      case 'location':
        return MdiIcons.key;
      case 'paiement':
        return MdiIcons.cash;
      case 'penalite':
        return MdiIcons.alert;
      case 'document':
        return MdiIcons.fileDocument;
      case 'commune':
        return MdiIcons.city;
      case 'commodite':
        return MdiIcons.lightbulb;
      case 'commodite-maison':
        return MdiIcons.homeModern;
      case 'photo':
        return MdiIcons.camera;
      default:
        return MdiIcons.help;
    }
  }
}
