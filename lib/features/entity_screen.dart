import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:gestion_immo/data/services/base_service.dart';
import 'package:gestion_immo/data/services/location_service.dart';
import 'package:gestion_immo/data/services/maison_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EntityScreen extends StatefulWidget {
  final String title;
  final BaseService service;
  final List<Map<String, dynamic>> fields;
  final IconData icon;
  final String routeName;

  const EntityScreen({
    super.key,
    required this.title,
    required this.service,
    required this.fields,
    required this.icon,
    required this.routeName,
  });

  @override
  _EntityScreenState createState() => _EntityScreenState();
}

class _EntityScreenState extends State<EntityScreen> {
  List<dynamic> items = [];
  bool isLoading = false;
  String? errorMessage;
  Map<String, List<Map<String, dynamic>>> optionsCache = {};
  String? currentUserAgenceId;

  @override
  void initState() {
    super.initState();
    _loadUserAgenceId();
    fetchItems();
    fetchOptions();
  }

  Future<void> _loadUserAgenceId() async {
    // Simuler la récupération de l'ID de l'agence de l'utilisateur connecté (à adapter selon votre AuthService)
    final userData = await AuthService().getUserData();
    setState(() {
      currentUserAgenceId = userData['agence_id']?.toString();
    });
  }

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final fetchedItems = await widget.service.getAll();
      setState(() {
        items = List<Map<String, dynamic>>.from(fetchedItems);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> fetchOptions() async {
    for (var field in widget.fields) {
      if (field['type'] == 'dropdown' || field['type'] == 'multi_select') {
        final endpoint = field['options_endpoint'];
        if (endpoint != null && !optionsCache.containsKey(endpoint)) {
          try {
            // Remplacez ceci par le service concret approprié selon l'endpoint
            late final dynamic service;
            if (endpoint == 'maisons') {
              service = MaisonService();
            } else if (endpoint == 'locations') {
              service = LocationService();
            } else {
              throw Exception('Aucun service concret pour $endpoint');
            }
            final response = await service.getAll();
            setState(() {
              optionsCache[endpoint] = (response as List<dynamic>)
                  .map((item) => {
                        'id': item['id'].toString(),
                        'label': item['nom']?.toString() ??
                            item['immatriculation']?.toString() ??
                            'N/A',
                        'immatriculation': item['immatriculation']?.toString(),
                        'etat': item['etat']
                            ?.toString(), // Pour filtrer les maisons
                        'agence_id': item['agence_id']
                            ?.toString(), // Pour filtrer par agence
                      })
                  .toList();
            });
          } catch (e) {
            setState(() {
              errorMessage =
                  'Erreur lors du chargement des options pour $endpoint: $e';
            });
          }
        }
      }
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await widget.service.delete(id);
      fetchItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _showFormDialog({dynamic item}) async {
    final isEditing = item != null;
    final formData = Map<String, dynamic>.from(item ?? {});
    final TextEditingController googleMapsController =
        TextEditingController(text: formData['google_maps_link'] ?? '');
    final List<String> photoPaths = List<String>.from(formData['photos'] ?? []);
    String? agenceImmatriculation;

    // Générer l'immatriculation pour une maison si une agence est sélectionnée
    if (widget.title == 'Maisons' && !isEditing) {
      final agenceId = formData['agence_id']?.toString();
      if (agenceId != null) {
        final options = optionsCache['agences'] ?? [];
        final selectedAgence = options.firstWhere(
          (option) => option['id'] == agenceId,
          orElse: () => {},
        );
        agenceImmatriculation = selectedAgence['immatriculation']?.toString();
        if (agenceImmatriculation != null) {
          formData['immatriculation'] =
              '$agenceImmatriculation-M${DateTime.now().millisecondsSinceEpoch}';
        }
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: 400,
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
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...widget.fields.map((field) {
                        if (field['type'] == 'dropdown') {
                          final options =
                              optionsCache[field['options_endpoint']] ?? [];
                          // Filtrer les maisons disponibles (état 'Libre' et agence correspondante)
                          final filteredOptions = widget.title == 'Locations' &&
                                  field['name'] == 'maison_id' &&
                                  currentUserAgenceId != null
                              ? options
                                  .where((option) =>
                                      option['etat'] == 'Libre' &&
                                      option['agence_id'] ==
                                          currentUserAgenceId)
                                  .toList()
                              : options;
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: field['label'],
                              prefixIcon:
                                  Icon(field['icon'], color: Colors.brown),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.brown),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.brown, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.brown[50],
                            ),
                            value: formData[field['name']]?.toString(),
                            items: filteredOptions.map((option) {
                              return DropdownMenuItem<String>(
                                value: option['id'],
                                child: Text(option['label']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              formData[field['name']] = value;
                              if (widget.title == 'Maisons' &&
                                  field['name'] == 'agence_id' &&
                                  !isEditing) {
                                final selectedAgence = options.firstWhere(
                                  (option) => option['id'] == value,
                                  orElse: () => {},
                                );
                                final immatriculation =
                                    selectedAgence['immatriculation']
                                        ?.toString();
                                if (immatriculation != null) {
                                  formData['immatriculation'] =
                                      '$immatriculation-M${DateTime.now().millisecondsSinceEpoch}';
                                }
                                setState(() {});
                              }
                            },
                          );
                        } else if (field['type'] == 'multi_select') {
                          final options =
                              optionsCache[field['options_endpoint']] ?? [];
                          final selectedIds =
                              List<String>.from(formData[field['name']] ?? []);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(field['icon'], color: Colors.brown),
                                  const SizedBox(width: 8),
                                  Text(field['label'],
                                      style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              ...options.map((option) {
                                return CheckboxListTile(
                                  title: Text(option['label']),
                                  value: selectedIds.contains(option['id']),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedIds.add(option['id']);
                                      } else {
                                        selectedIds.remove(option['id']);
                                      }
                                      formData[field['name']] = selectedIds;
                                    });
                                  },
                                );
                              }).toList(),
                            ],
                          );
                        } else if (field['type'] == 'photo_list') {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(field['icon'], color: Colors.brown),
                                  const SizedBox(width: 8),
                                  Text(field['label'],
                                      style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              Wrap(
                                spacing: 8,
                                children: photoPaths.map((path) {
                                  return Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        width: 100,
                                        height: 100,
                                        child: Image.file(File(path),
                                            fit: BoxFit.cover),
                                      ),
                                      Positioned(
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.remove_circle,
                                              color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              photoPaths.remove(path);
                                              formData[field['name']] =
                                                  photoPaths;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    setState(() {
                                      photoPaths.add(pickedFile.path);
                                      formData[field['name']] = photoPaths;
                                    });
                                  }
                                },
                                child: const Text('Ajouter une photo'),
                              ),
                            ],
                          );
                        } else if (field['name'] == 'google_maps_link') {
                          return TextFormField(
                            controller: googleMapsController,
                            decoration: InputDecoration(
                              labelText: field['label'],
                              prefixIcon:
                                  Icon(field['icon'], color: Colors.brown),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.brown),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.brown, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.brown[50],
                            ),
                            onChanged: (value) {
                              formData[field['name']] = value;
                            },
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TextFormField(
                              initialValue:
                                  formData[field['name']]?.toString() ?? '',
                              readOnly: field['readOnly'] == true,
                              decoration: InputDecoration(
                                labelText: field['label'],
                                prefixIcon:
                                    Icon(field['icon'], color: Colors.brown),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.brown),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Colors.brown, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.brown[50],
                              ),
                              keyboardType: field['type'] == 'number'
                                  ? TextInputType.number
                                  : field['type'] == 'email'
                                      ? TextInputType.emailAddress
                                      : TextInputType.text,
                              onChanged: (value) {
                                formData[field['name']] =
                                    field['type'] == 'number'
                                        ? num.tryParse(value) ?? 0
                                        : value;
                              },
                            ),
                          );
                        }
                      }).toList(),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Annuler',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                if (isEditing) {
                                  await widget.service
                                      .update(formData['id'], formData);
                                } else {
                                  if (photoPaths.isNotEmpty) {
                                    for (var path in photoPaths) {
                                      final photoData = {
                                        'url': path,
                                        'description':
                                            'Photo de ${widget.title.toLowerCase()}',
                                        'maison_id': formData['id'],
                                      };
                                      await MaisonService().createWithImage(
                                        photoData,
                                        imagePath: path,
                                        imageField: 'url',
                                      );
                                    }
                                  }
                                  await widget.service.create(formData);
                                }
                                Navigator.pop(context);
                                fetchItems();
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
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _cloturerLocation(int id, int maisonId) async {
    try {
      final locationService = LocationService();
      await locationService.cloturerLocation(id, maisonId);
      fetchItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la clôture: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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

  Widget _buildSidebarItem(IconData icon, String title, VoidCallback onTap,
      [bool isSelected = false]) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: title,
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[300],
            size: 26,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[300],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          onTap: onTap,
          tileColor: isSelected ? Colors.brown[600] : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          Container(
            width: 250,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.brown[900],
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(
                    MdiIcons.menu,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
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
                            title: Text(
                              'Déconnexion',
                              style: TextStyle(color: Colors.grey[300]),
                            ),
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
                            onPressed: fetchItems,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.brown))
                        : errorMessage != null
                            ? Center(child: Text(errorMessage!))
                            : items.isEmpty
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
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final item = items[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
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
                                            item['numero'] ?? 'Sans numéro',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.brown,
                                            ),
                                          ),
                                          subtitle: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ...widget.fields.map((field) {
                                                  if (field['name'] ==
                                                      'numero') {
                                                    return const SizedBox
                                                        .shrink(); // Déjà affiché dans le titre
                                                  } else if (field['type'] ==
                                                      'dropdown') {
                                                    final options =
                                                        optionsCache[field[
                                                                'options_endpoint']] ??
                                                            [];
                                                    final selectedOption =
                                                        options.firstWhere(
                                                      (option) =>
                                                          option['id'] ==
                                                          item[field['name']]
                                                              ?.toString(),
                                                      orElse: () =>
                                                          {'label': 'N/A'},
                                                    );
                                                    return Text(
                                                      '${field['label']}: ${selectedOption['label']}',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    );
                                                  } else if (field['type'] ==
                                                      'multi_select') {
                                                    final options =
                                                        optionsCache[field[
                                                                'options_endpoint']] ??
                                                            [];
                                                    final selectedIds = List<
                                                            String>.from(
                                                        item[field['name']] ??
                                                            []);
                                                    final selectedLabels = options
                                                        .where((option) =>
                                                            selectedIds
                                                                .contains(
                                                                    option[
                                                                        'id']))
                                                        .map((option) =>
                                                            option['label'])
                                                        .join(', ');
                                                    return Text(
                                                      '${field['label']}: ${selectedLabels.isEmpty ? 'Aucune sélection' : selectedLabels}',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    );
                                                  } else if (field['name'] ==
                                                      'photos') {
                                                    final photoCount = (item[
                                                                    field[
                                                                        'name']]
                                                                as List<
                                                                    dynamic>?)
                                                            ?.length ??
                                                        0;
                                                    return Text(
                                                      '${field['label']}: $photoCount photo${photoCount != 1 ? 's' : ''}',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    );
                                                  } else {
                                                    return Text(
                                                      '${field['label']}: ${item[field['name']] ?? 'N/A'}',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    );
                                                  }
                                                }),
                                              ],
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (widget.title == 'Locations')
                                                IconButton(
                                                  icon: const Icon(Icons.close,
                                                      color: Colors.red),
                                                  onPressed: () =>
                                                      _cloturerLocation(
                                                          item['id'],
                                                          item['maison_id']),
                                                  tooltip: 'Clôturer Location',
                                                ),
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    color: Colors.blueAccent),
                                                onPressed: () =>
                                                    _showFormDialog(item: item),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.redAccent),
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
                        onPressed: () => _showFormDialog(),
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          'Ajouter ${widget.title}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
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
}
