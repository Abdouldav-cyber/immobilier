import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:gestion_immo/data/services/base_service.dart';
import 'package:gestion_immo/data/services/agence_service.dart';
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
  List<String> photoPaths = [];
  String? selectedLogoPath;
  Map<String, dynamic>? selectedAgence;
  DateTime? selectedDateDebut;
  DateTime? selectedDateFin;

  @override
  void initState() {
    super.initState();
    _loadUserAgenceId();
    fetchItems();
    fetchOptions();
  }

  Future<void> _loadUserAgenceId() async {
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
        errorMessage = 'Erreur lors du chargement des données: $e';
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
      if (field['type'] == 'dropdown') {
        final endpoint = field['options_endpoint'];
        if (endpoint != null && !optionsCache.containsKey(endpoint)) {
          try {
            late final dynamic service;
            if (endpoint == 'agences') {
              service = AgenceService();
            } else if (endpoint == 'maisons') {
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
                            item['numero']?.toString() ??
                            'N/A',
                        'agence_id': item['agence_id']?.toString(),
                      })
                  .toList();
            });
          } catch (e) {
            setState(() {
              errorMessage =
                  'Erreur lors du chargement des options pour $endpoint: $e';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors du chargement des options: $e'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _deleteItem(int id) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Confirmer la suppression',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        content: const Text('Voulez-vous vraiment supprimer cet élément ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await widget.service.delete(id);
        setState(() {
          selectedAgence = null;
        });
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
  }

  Future<void> _showFormDialog({dynamic item}) async {
    final isEditing = item != null;
    final formData = Map<String, dynamic>.from(item ?? {});
    photoPaths = List<String>.from(formData['photos'] ?? []);
    selectedLogoPath = formData['logo'];
    selectedDateDebut = formData['date_debut'] != null
        ? DateTime.parse(formData['date_debut'])
        : null;
    selectedDateFin = formData['date_fin'] != null
        ? DateTime.parse(formData['date_fin'])
        : null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.grey[100],
          content: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                          IconButton(
                            icon: Icon(MdiIcons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Filtrer les champs à exclure
                      ...widget.fields
                          .where((field) =>
                              field['name'] != 'latitude' &&
                              field['name'] != 'longitude' &&
                              field['name'] != 'latitude_degrees' &&
                              field['name'] != 'latitude_minutes' &&
                              field['name'] != 'latitude_seconds' &&
                              field['name'] != 'longitude_degrees' &&
                              field['name'] != 'longitude_minutes' &&
                              field['name'] != 'longitude_seconds' &&
                              (widget.title == 'Maisons'
                                  ? (field['name'] != 'type_document_id' &&
                                      field['name'] != 'commodite_id' &&
                                      field['name'] != 'coordonnees')
                                  : true) &&
                              (widget.title == 'Locations' ||
                                      widget.title == 'Agences'
                                  ? field['name'] != 'coordonnees'
                                  : true))
                          .map((field) {
                        if (field['name'] == 'agence_id') {
                          final options = optionsCache['agences'] ?? [];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Agences',
                                labelStyle:
                                    const TextStyle(color: Colors.brown),
                                prefixIcon: Icon(MdiIcons.officeBuilding,
                                    color: Colors.brown[700]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide:
                                      const BorderSide(color: Colors.brown),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: Colors.brown, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.brown[50],
                              ),
                              value: formData[field['name']]?.toString(),
                              items: options.map((option) {
                                return DropdownMenuItem<String>(
                                  value: option['id'],
                                  child: Row(
                                    children: [
                                      Icon(MdiIcons.checkCircle,
                                          color: Colors.green[700], size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        option['label'],
                                        style: const TextStyle(
                                            color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                formData[field['name']] = value;
                              },
                            ),
                          );
                        } else if (field['name'] == 'maison_id') {
                          final options = optionsCache['maisons'] ?? [];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Maison',
                                labelStyle:
                                    const TextStyle(color: Colors.brown),
                                prefixIcon: Icon(MdiIcons.home,
                                    color: Colors.brown[700]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide:
                                      const BorderSide(color: Colors.brown),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: Colors.brown, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.brown[50],
                              ),
                              value: formData[field['name']]?.toString(),
                              items: options.map((option) {
                                return DropdownMenuItem<String>(
                                  value: option['id'],
                                  child: Row(
                                    children: [
                                      Icon(MdiIcons.checkCircle,
                                          color: Colors.green[700], size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        option['label'],
                                        style: const TextStyle(
                                            color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                formData[field['name']] =
                                    int.tryParse(value ?? '0') ?? 0;
                              },
                            ),
                          );
                        } else if (field['name'] == 'date_debut' ||
                            field['name'] == 'date_fin') {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GestureDetector(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Colors.brown,
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                        dialogBackgroundColor: Colors.white,
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() {
                                    if (field['name'] == 'date_debut') {
                                      selectedDateDebut = picked;
                                      formData['date_debut'] =
                                          picked.toIso8601String();
                                    } else {
                                      selectedDateFin = picked;
                                      formData['date_fin'] =
                                          picked.toIso8601String();
                                    }
                                  });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.brown),
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.brown[50],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(MdiIcons.calendar,
                                        color: Colors.brown[700]),
                                    const SizedBox(width: 8),
                                    Text(
                                      field['name'] == 'date_debut'
                                          ? (selectedDateDebut != null
                                              ? '${selectedDateDebut!.day}/${selectedDateDebut!.month}/${selectedDateDebut!.year}'
                                              : 'Sélectionner Date Début')
                                          : (selectedDateFin != null
                                              ? '${selectedDateFin!.day}/${selectedDateFin!.month}/${selectedDateFin!.year}'
                                              : 'Sélectionner Date Fin'),
                                      style: const TextStyle(
                                          color: Colors.black87, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                                labelStyle:
                                    const TextStyle(color: Colors.brown),
                                prefixIcon: Icon(
                                  field['icon'] ?? MdiIcons.text,
                                  color: Colors.brown[700],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide:
                                      const BorderSide(color: Colors.brown),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
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
                      // Champs supplémentaires pour Agences : Nom et Immatriculation
                      if (widget.title == 'Agences') ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            initialValue: formData['nom']?.toString() ?? '',
                            decoration: InputDecoration(
                              labelText: 'Nom de l\'agence',
                              labelStyle: const TextStyle(color: Colors.brown),
                              prefixIcon: Icon(MdiIcons.officeBuilding,
                                  color: Colors.brown[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    const BorderSide(color: Colors.brown),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: Colors.brown, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.brown[50],
                            ),
                            onChanged: (value) {
                              formData['nom'] = value;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            initialValue:
                                formData['immatriculation']?.toString() ?? '',
                            decoration: InputDecoration(
                              labelText: 'Immatriculation',
                              labelStyle: const TextStyle(color: Colors.brown),
                              prefixIcon: Icon(MdiIcons.cardText,
                                  color: Colors.brown[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    const BorderSide(color: Colors.brown),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: Colors.brown, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.brown[50],
                            ),
                            onChanged: (value) {
                              formData['immatriculation'] = value;
                            },
                          ),
                        ),
                      ],
                      // Champs supplémentaires pour Maisons : Loyer et État
                      if (widget.title == 'Maisons') ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            initialValue: formData['loyer']?.toString() ?? '',
                            decoration: InputDecoration(
                              labelText: 'Loyer',
                              labelStyle: const TextStyle(color: Colors.brown),
                              prefixIcon: Icon(MdiIcons.currencyUsd,
                                  color: Colors.brown[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    const BorderSide(color: Colors.brown),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: Colors.brown, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.brown[50],
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              formData['loyer'] = num.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'État de la maison',
                              labelStyle: const TextStyle(color: Colors.brown),
                              prefixIcon:
                                  Icon(MdiIcons.home, color: Colors.brown[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    const BorderSide(color: Colors.brown),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: Colors.brown, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.brown[50],
                            ),
                            value: formData['etat'] ?? 'Libre',
                            items: ['Libre', 'Occupée'].map((String etat) {
                              return DropdownMenuItem<String>(
                                value: etat,
                                child: Row(
                                  children: [
                                    Icon(
                                      etat == 'Libre'
                                          ? MdiIcons.doorOpen
                                          : MdiIcons.doorClosed,
                                      color: Colors.brown[700],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      etat,
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              formData['etat'] = value;
                            },
                          ),
                        ),
                      ],
                      // Bouton pour ajouter un logo (uniquement pour Agences)
                      if (widget.title == 'Agences')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(MdiIcons.image, color: Colors.brown[700]),
                                const SizedBox(width: 8),
                                const Text('Logo de l\'agence',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (selectedLogoPath != null)
                              Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(selectedLogoPath!),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              MdiIcons.alertCircle,
                                              color: Colors.redAccent,
                                              size: 40,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                      icon: Icon(MdiIcons.closeCircle,
                                          color: Colors.redAccent),
                                      onPressed: () {
                                        setState(() {
                                          selectedLogoPath = null;
                                          formData['logo'] = null;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    setState(() {
                                      selectedLogoPath = pickedFile.path;
                                      formData['logo'] = selectedLogoPath;
                                    });
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Erreur lors du chargement du logo: $e'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                              icon:
                                  Icon(MdiIcons.imagePlus, color: Colors.white),
                              label: const Text('Ajouter un logo',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                elevation: 5,
                                shadowColor: Colors.brown[800],
                              ),
                            ),
                          ],
                        ),
                      // Section pour ajouter des photos (uniquement pour Maisons)
                      if (widget.title == 'Maisons')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(MdiIcons.imageMultiple,
                                    color: Colors.brown[700]),
                                const SizedBox(width: 8),
                                const Text('Photos',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: photoPaths.map((path) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          File(path),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                              child: Icon(
                                                MdiIcons.alertCircle,
                                                color: Colors.redAccent,
                                                size: 40,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: IconButton(
                                        icon: Icon(MdiIcons.closeCircle,
                                            color: Colors.redAccent),
                                        onPressed: () {
                                          setState(() {
                                            photoPaths.remove(path);
                                            formData['photos'] = photoPaths;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  final picker = ImagePicker();
                                  final pickedFiles =
                                      await picker.pickMultiImage();
                                  if (pickedFiles.isNotEmpty) {
                                    setState(() {
                                      photoPaths.addAll(
                                          pickedFiles.map((e) => e.path));
                                      formData['photos'] = photoPaths;
                                    });
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Erreur lors du chargement des photos: $e'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                              icon:
                                  Icon(MdiIcons.imagePlus, color: Colors.white),
                              label: const Text('Ajouter des photos',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                elevation: 5,
                                shadowColor: Colors.brown[800],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              shadowColor: Colors.grey[600],
                              animationDuration:
                                  const Duration(milliseconds: 300),
                            ),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                if (isEditing) {
                                  await widget.service
                                      .update(formData['id'], formData);
                                } else {
                                  if (widget.title == 'Maisons' &&
                                      photoPaths.isNotEmpty) {
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
                                  if (widget.title == 'Agences' &&
                                      selectedLogoPath != null) {
                                    final logoData = {
                                      'logo': selectedLogoPath,
                                      'description': 'Logo de l\'agence',
                                    };
                                    await AgenceService().createWithImage(
                                      logoData,
                                      imagePath: selectedLogoPath!,
                                      imageField: 'logo',
                                    );
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              shadowColor: Colors.brown[800],
                              animationDuration:
                                  const Duration(milliseconds: 300),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.brown[600],
                            ),
                            child: Text(
                              isEditing ? 'Modifier' : 'Ajouter',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
                        Icons.settings,
                        'Paramètres',
                        () => Navigator.pushNamed(context, Routes.parametres),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.brown[600]!,
                                  Colors.brown[800]!
                                ],
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
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white),
                                  onPressed: fetchItems,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.brown))
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
                                              margin:
                                                  const EdgeInsets.symmetric(
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
                                                  backgroundColor:
                                                      Colors.brown[100],
                                                  child: Icon(
                                                    widget.icon,
                                                    color: Colors.brown,
                                                  ),
                                                ),
                                                title: Text(
                                                  item['nom'] ??
                                                      item['numero'] ??
                                                      'Sans nom',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.brown,
                                                  ),
                                                ),
                                                subtitle: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ...widget.fields
                                                          .where((field) =>
                                                              field['name'] !=
                                                                  'latitude' &&
                                                              field['name'] !=
                                                                  'longitude' &&
                                                              field['name'] !=
                                                                  'latitude_degrees' &&
                                                              field['name'] !=
                                                                  'latitude_minutes' &&
                                                              field['name'] !=
                                                                  'latitude_seconds' &&
                                                              field['name'] !=
                                                                  'longitude_degrees' &&
                                                              field['name'] !=
                                                                  'longitude_minutes' &&
                                                              field['name'] !=
                                                                  'longitude_seconds' &&
                                                              (widget.title ==
                                                                      'Maisons'
                                                                  ? (field[
                                                                              'name'] !=
                                                                          'type_document_id' &&
                                                                      field['name'] !=
                                                                          'commodite_id' &&
                                                                      field['name'] !=
                                                                          'coordonnees')
                                                                  : true) &&
                                                              (widget.title ==
                                                                          'Locations' ||
                                                                      widget.title ==
                                                                          'Agences'
                                                                  ? field['name'] !=
                                                                      'coordonnees'
                                                                  : true))
                                                          .map((field) {
                                                        if (field['name'] ==
                                                                'nom' ||
                                                            field['name'] ==
                                                                'numero') {
                                                          return const SizedBox
                                                              .shrink();
                                                        } else if (field[
                                                                'type'] ==
                                                            'dropdown') {
                                                          final options =
                                                              optionsCache[field[
                                                                      'options_endpoint']] ??
                                                                  [];
                                                          final selectedOption =
                                                              options
                                                                  .firstWhere(
                                                            (option) =>
                                                                option['id'] ==
                                                                item[field[
                                                                        'name']]
                                                                    ?.toString(),
                                                            orElse: () => {
                                                              'label': 'N/A'
                                                            },
                                                          );
                                                          return Text(
                                                            '${field['label']}: ${selectedOption['label']}',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[600],
                                                              fontSize: 14,
                                                            ),
                                                          );
                                                        } else {
                                                          return Text(
                                                            '${field['label']}: ${item[field['name']] ?? 'N/A'}',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[600],
                                                              fontSize: 14,
                                                            ),
                                                          );
                                                        }
                                                      }),
                                                      if (widget.title ==
                                                          'Maisons') ...[
                                                        Text(
                                                          'Loyer: ${item['loyer'] ?? 'N/A'}',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          'État: ${item['etat'] ?? 'N/A'}',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                onTap: widget.title == 'Agences'
                                                    ? () {
                                                        setState(() {
                                                          selectedAgence = item;
                                                        });
                                                      }
                                                    : null,
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (widget.title ==
                                                        'Locations')
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.close,
                                                            color: Colors.red),
                                                        onPressed: () =>
                                                            _cloturerLocation(
                                                                item['id'],
                                                                item[
                                                                    'maison_id']),
                                                        tooltip:
                                                            'Clôturer Location',
                                                      ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.edit,
                                                          color: Colors
                                                              .blueAccent),
                                                      onPressed: () =>
                                                          _showFormDialog(
                                                              item: item),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.delete,
                                                          color:
                                                              Colors.redAccent),
                                                      onPressed: () =>
                                                          _deleteItem(
                                                              item['id']),
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
                              icon: Icon(MdiIcons.plus, size: 20),
                              label: Text(
                                'Ajouter ${widget.title}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                shadowColor: Colors.brown[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.title == 'Agences' && selectedAgence != null)
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Détails de l\'agence',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(MdiIcons.close,
                                            color: Colors.grey),
                                        onPressed: () {
                                          setState(() {
                                            selectedAgence = null;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (selectedAgence!['logo'] != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(selectedAgence!['logo']),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              MdiIcons.alertCircle,
                                              color: Colors.redAccent,
                                              size: 40,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Nom: ${selectedAgence!['nom'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Immatriculation: ${selectedAgence!['immatriculation'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  ...widget.fields
                                      .where((field) =>
                                          field['name'] != 'nom' &&
                                          field['name'] != 'immatriculation' &&
                                          field['name'] != 'latitude' &&
                                          field['name'] != 'longitude' &&
                                          field['name'] != 'latitude_degrees' &&
                                          field['name'] != 'latitude_minutes' &&
                                          field['name'] != 'latitude_seconds' &&
                                          field['name'] !=
                                              'longitude_degrees' &&
                                          field['name'] !=
                                              'longitude_minutes' &&
                                          field['name'] !=
                                              'longitude_seconds' &&
                                          field['name'] != 'type_document_id' &&
                                          field['name'] != 'commodite_id' &&
                                          field['name'] != 'photos' &&
                                          field['name'] != 'logo' &&
                                          field['name'] != 'coordonnees')
                                      .map((field) {
                                    if (field['type'] == 'dropdown') {
                                      final options = optionsCache[
                                              field['options_endpoint']] ??
                                          [];
                                      final selectedOption = options.firstWhere(
                                        (option) =>
                                            option['id'] ==
                                            selectedAgence![field['name']]
                                                ?.toString(),
                                        orElse: () => {'label': 'N/A'},
                                      );
                                      return Text(
                                        '${field['label']}: ${selectedOption['label']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      );
                                    }
                                    return Text(
                                      '${field['label']}: ${selectedAgence![field['name']] ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
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
