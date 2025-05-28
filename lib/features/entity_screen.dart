import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:gestion_immo/data/services/base_service.dart';
import 'package:image_picker/image_picker.dart'; // Pour sélectionner des images
import 'dart:io';

class EntityScreen extends StatefulWidget {
  final BaseService service;
  final String title;
  final List<Map<String, dynamic>> fields; // Liste des champs (nom, type, etc.)
  final IconData icon;
  final String routeName;

  const EntityScreen({
    super.key,
    required this.service,
    required this.title,
    required this.fields,
    required this.icon,
    required this.routeName,
  });

  @override
  State<EntityScreen> createState() => _EntityScreenState();
}

class _EntityScreenState extends State<EntityScreen> {
  bool _isSidebarOpen = false;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  Map<String, dynamic>? _editingItem;
  String? _imagePath; // Chemin de l'image sélectionnée

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await widget.service.getAll();
      setState(() {
        _items = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await widget.service.update(id, {'sup': true});
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _updateStatus(int id) async {
    try {
      // Remplace closeLocation par updateStatus
      await widget.service.updateStatus(id, 'status', 'closed');
      _loadData();
      setState(() => _editingItem = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du statut: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _showAddDialog({Map<String, dynamic>? item}) {
    final isEditing = item != null;
    _editingItem = isEditing ? Map<String, dynamic>.from(item) : null;
    final controllers = widget.fields.map((field) {
      return TextEditingController(
        text: isEditing ? (_editingItem?[field['name']]?.toString() ?? '') : '',
      );
    }).toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing
                          ? 'Modifier ${widget.title}'
                          : 'Ajouter ${widget.title}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        setState(() => _imagePath = null);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...widget.fields.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> field = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: controllers[index],
                      keyboardType: field['type'] == 'number'
                          ? TextInputType.number
                          : field['type'] == 'email'
                              ? TextInputType.emailAddress
                              : TextInputType.text,
                      decoration: InputDecoration(
                        labelText: field['label'],
                        prefixIcon: Icon(field['icon'], color: Colors.brown),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.brown),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.brown, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.brown[50],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: Text(_imagePath == null
                          ? 'Choisir une image'
                          : 'Image sélectionnée'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[200],
                        foregroundColor: Colors.brown,
                      ),
                    ),
                    if (_imagePath != null) ...[
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () => setState(() => _imagePath = null),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() => _imagePath = null);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final data = <String, dynamic>{};
                        for (int i = 0; i < widget.fields.length; i++) {
                          final field = widget.fields[i];
                          final value = controllers[i].text;
                          if (value.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${field['label']} est requis'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }
                          data[field['name']] = field['type'] == 'number'
                              ? double.tryParse(value) ?? 0
                              : value;
                        }
                        data['sup'] = false;

                        try {
                          if (isEditing) {
                            await widget.service
                                .update(_editingItem!['id'], data);
                          } else {
                            // Utilisation de createWithImage pour ajouter une image
                            await widget.service.createWithImage(
                              data,
                              imagePath: _imagePath,
                              imageField:
                                  'image', // Champ attendu par l'API pour l'image
                            );
                          }
                          setState(() => _imagePath = null);
                          Navigator.pop(context);
                          _loadData();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Erreur lors de l\'${isEditing ? 'édition' : 'ajout'}: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: Text(
                        isEditing ? 'Modifier' : 'Ajouter',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
  }

  Future<void> _logout() async {
    try {
      await AuthService().logout();
      Navigator.pushReplacementNamed(context, Routes.login);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarOpen ? 250 : 70,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.brown[900],
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 0)),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(
                    _isSidebarOpen ? MdiIcons.close : MdiIcons.menu,
                    color: Colors.white,
                  ),
                  title: _isSidebarOpen
                      ? const Text(
                          'Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                  onTap: _toggleSidebar,
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildSidebarItem(
                        Icons.home,
                        'Accueil',
                        () => Navigator.pushNamed(context, Routes.home),
                      ),
                      _buildSidebarItem(
                        Icons.view_agenda,
                        'Maisons',
                        () => Navigator.pushNamed(context, Routes.maisons),
                      ),
                      _buildSidebarItem(
                        Icons.business,
                        'Agences',
                        () => Navigator.pushNamed(context, Routes.agences),
                      ),
                      _buildSidebarItem(
                        Icons.location_on,
                        'Locations',
                        () => Navigator.pushNamed(context, Routes.locations),
                      ),
                      _buildSidebarItem(
                        Icons.payment,
                        'Paiements',
                        () => Navigator.pushNamed(context, Routes.paiements),
                      ),
                      _buildSidebarItem(
                        Icons.warning,
                        'Pénalités',
                        () => Navigator.pushNamed(context, Routes.penalites),
                      ),
                      _buildSidebarItem(
                        Icons.description,
                        'Types de Documents',
                        () =>
                            Navigator.pushNamed(context, Routes.type_documents),
                      ),
                      _buildSidebarItem(
                        Icons.location_city,
                        'Communes',
                        () => Navigator.pushNamed(context, Routes.communes),
                      ),
                      _buildSidebarItem(
                        Icons.lightbulb,
                        'Commodités',
                        () => Navigator.pushNamed(context, Routes.commodites),
                      ),
                      _buildSidebarItem(
                        Icons.house,
                        'Commodités Maisons',
                        () => Navigator.pushNamed(
                            context, Routes.commoditeMaisons),
                      ),
                      _buildSidebarItem(
                        Icons.photo,
                        'Photos',
                        () => Navigator.pushNamed(context, Routes.photos),
                      ),
                      _buildSidebarItem(
                        widget.icon,
                        widget.title,
                        () => setState(() {}),
                        true,
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Tooltip(
                          message: 'Déconnexion',
                          child: ListTile(
                            leading:
                                Icon(Icons.logout, color: Colors.grey[300]),
                            title: _isSidebarOpen
                                ? Text(
                                    'Déconnexion',
                                    style: TextStyle(color: Colors.grey[300]),
                                  )
                                : null,
                            onTap: _logout,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.brown[600]!, Colors.brown[800]!],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                            onPressed: _loadData,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.brown))
                        : _items.isEmpty
                            ? Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 50),
                                    Icon(
                                      widget.icon,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Aucune donnée pour le moment',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.brown[100],
                                        child: Icon(
                                          widget.icon,
                                          color: Colors.brown,
                                        ),
                                      ),
                                      title: Text(
                                        item[widget.fields[0]['name']] ??
                                            'Sans nom',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.brown,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ...widget.fields
                                                .skip(1)
                                                .map((field) => Text(
                                                      '${field['label']}: ${item[field['name']] ?? 'N/A'}',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    )),
                                            Text(
                                              'Supprimé: ${item['sup'] ? 'Oui' : 'Non'}',
                                              style: TextStyle(
                                                color: item['sup']
                                                    ? Colors.redAccent
                                                    : Colors.green,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (item['status'] != null)
                                              Text(
                                                'Statut: ${item['status']}',
                                                style: TextStyle(
                                                  color:
                                                      item['status'] == 'closed'
                                                          ? Colors.redAccent
                                                          : Colors.green,
                                                  fontSize: 14,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (item['status'] != null &&
                                              item['status'] != 'closed')
                                            IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.orange,
                                              ),
                                              onPressed: () =>
                                                  _updateStatus(item['id']),
                                            ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blueAccent,
                                            ),
                                            onPressed: () =>
                                                _showAddDialog(item: item),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () =>
                                                _deleteItem(item['id']),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddDialog(),
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          'Ajouter ${widget.title}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, VoidCallback onTap,
      [bool isSelected = false]) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: title,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: ListTile(
            leading: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[300],
              size: 26,
            ),
            title: _isSidebarOpen
                ? Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[300],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  )
                : null,
            onTap: onTap,
            tileColor: isSelected ? Colors.brown[600] : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
