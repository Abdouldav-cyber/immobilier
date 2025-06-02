import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:gestion_immo/data/services/base_service.dart';
import 'package:gestion_immo/data/services/agence_service.dart';
import 'package:gestion_immo/data/services/location_service.dart';
import 'package:gestion_immo/data/services/maison_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  String? selectedLogoPath;
  List<String>? selectedPhotoPaths;
  Map<String, dynamic>? selectedItem;
  DateTime? selectedDateDebut;
  DateTime? selectedDateFin;
  DateTime? selectedDate;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserAgenceId();
    fetchItems();
    fetchOptions();
  }

  Future<void> _loadUserAgenceId() async {
    try {
      final userData = await AuthService().getUserData();
      if (mounted) {
        setState(() {
          currentUserAgenceId = userData['agence_id']?.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Erreur lors de la récupération de l\'agence: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur lors de la récupération des données utilisateur: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final fetchedItems = await widget.service.getAll();
      if (fetchedItems is List && fetchedItems.isNotEmpty) {
        setState(() {
          items = List<Map<String, dynamic>>.from(fetchedItems);
          isLoading = false;
        });
      } else {
        setState(() {
          items = [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        setState(() {
          errorMessage =
              'Utilisateur non authentifié. Veuillez vous reconnecter.';
          isLoading = false;
        });
        await AuthService().logout();
        Navigator.pushReplacementNamed(context, Routes.login);
      } else {
        setState(() {
          errorMessage = 'Erreur lors du chargement des données: $e';
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> fetchOptions() async {
    for (var field in widget.fields) {
      if (field['type'] == 'dropdown' || field['type'] == 'multi_select') {
        final endpoint = field['options_endpoint'];
        if (endpoint != null && !optionsCache.containsKey(endpoint)) {
          try {
            late final dynamic service;
            if (endpoint == 'agences') service = AgenceService();
            if (endpoint == 'maisons') service = MaisonService();
            if (endpoint == 'locations') service = LocationService();
            final response = await service.getAll();
            if (response is List && response.isNotEmpty) {
              setState(() {
                optionsCache[endpoint] = (response as List<dynamic>)
                    .map((item) => {
                          'id': item['id'].toString(),
                          'label': item['nom']?.toString() ??
                              item['numero']?.toString() ??
                              item['locataire']?.toString() ??
                              'N/A',
                          'agence_id': item['agence_id']?.toString(),
                        })
                    .toList();
              });
            }
          } catch (e) {
            if (e.toString().contains('401')) {
              setState(() {
                errorMessage =
                    'Utilisateur non authentifié pour $endpoint. Veuillez vous reconnecter.';
              });
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, Routes.login);
            } else {
              setState(() {
                errorMessage = 'Erreur options pour $endpoint: $e';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Erreur options: $e'),
                    backgroundColor: Colors.redAccent),
              );
            }
          }
        }
      }
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
            backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _deleteItem(int id) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Confirmer la suppression',
            style:
                TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment supprimer cet élément ?',
            style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Non', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Oui', style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
    if (confirmDelete == true) {
      try {
        await widget.service.delete(id);
        setState(() => selectedItem = null);
        fetchItems();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Élément supprimé avec succès'),
              backgroundColor: Colors.green[600]),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur suppression: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _pickImage({required bool isLogo}) async {
    try {
      if (!kIsWeb) {
        final status = await Permission.photos.request();
        if (status.isGranted) {
          final picker = ImagePicker();
          if (isLogo) {
            final pickedFile =
                await picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null && mounted) {
              setState(() {
                selectedLogoPath = pickedFile.path;
              });
            }
          } else {
            final pickedFiles = await picker.pickMultiImage();
            if (pickedFiles != null && pickedFiles.isNotEmpty && mounted) {
              setState(() {
                selectedPhotoPaths =
                    pickedFiles.map((file) => file.path).toList();
              });
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Permission refusée'),
                backgroundColor: Colors.redAccent),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'La sélection de photos n\'est pas supportée sur le web. Utilisez un appareil mobile.'),
            backgroundColor: Colors.yellow[700],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _showFormDialog({dynamic item}) async {
    final isEditing = item != null;
    final formData = Map<String, dynamic>.from(item ?? {});
    selectedLogoPath = formData['logo'];
    selectedPhotoPaths =
        formData['photos'] != null ? List<String>.from(formData['photos']) : [];
    selectedDateDebut = formData['date_debut'] != null
        ? DateTime.parse(formData['date_debut'])
        : null;
    selectedDateFin = formData['date_fin'] != null
        ? DateTime.parse(formData['date_fin'])
        : null;
    selectedDate =
        formData['date'] != null ? DateTime.parse(formData['date']) : null;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 10,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            minWidth: 400,
            maxWidth: 800,
            minHeight: 300,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
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
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo[900],
                            ),
                          ),
                          IconButton(
                            icon: Icon(MdiIcons.close,
                                color: Colors.grey[700], size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ...widget.fields
                          .where((field) => ![
                                'latitude',
                                'longitude',
                                'latitude_degrees',
                                'latitude_minutes',
                                'latitude_seconds',
                                'longitude_degrees',
                                'longitude_minutes',
                                'longitude_seconds'
                              ].contains(field['name']))
                          .map((field) {
                        if (field['type'] == 'dropdown') {
                          final options =
                              optionsCache[field['options_endpoint']] ?? [];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: field['label'],
                                labelStyle: TextStyle(
                                    color: Colors.indigo[900], fontSize: 16),
                                prefixIcon: Icon(field['icon'],
                                    color: Colors.indigo[700], size: 24),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide:
                                      BorderSide(color: Colors.indigo[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                      color: Colors.indigo[900]!, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide:
                                      BorderSide(color: Colors.indigo[200]!),
                                ),
                                filled: true,
                                fillColor: Colors.indigo[50],
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                              ),
                              value: formData[field['name']]?.toString(),
                              items: options
                                  .map((option) => DropdownMenuItem<String>(
                                        value: option['id'],
                                        child: Text(option['label'],
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16)),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  formData[field['name']] = value,
                              dropdownColor: Colors.white,
                              icon: Icon(MdiIcons.chevronDown,
                                  color: Colors.indigo[700], size: 24),
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 16),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          );
                        } else if (field['type'] == 'date') {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) => Theme(
                                    data: ThemeData.light().copyWith(
                                      primaryColor: Colors.indigo[700],
                                      colorScheme: ColorScheme.light(
                                          primary: Colors.indigo[700]!),
                                      buttonTheme: ButtonThemeData(
                                          textTheme: ButtonTextTheme.primary),
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (picked != null && mounted) {
                                  setState(() {
                                    if (field['name'] == 'date_debut') {
                                      selectedDateDebut = picked;
                                      formData['date_debut'] =
                                          picked.toIso8601String();
                                    } else if (field['name'] == 'date_fin') {
                                      selectedDateFin = picked;
                                      formData['date_fin'] =
                                          picked.toIso8601String();
                                    } else if (field['name'] == 'date') {
                                      selectedDate = picked;
                                      formData['date'] =
                                          picked.toIso8601String();
                                    }
                                  });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.indigo[200]!),
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.indigo[50],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                child: Row(
                                  children: [
                                    Icon(MdiIcons.calendar,
                                        color: Colors.indigo[700], size: 24),
                                    const SizedBox(width: 12),
                                    Text(
                                      field['name'] == 'date_debut'
                                          ? (selectedDateDebut != null
                                              ? '${selectedDateDebut!.day}/${selectedDateDebut!.month}/${selectedDateDebut!.year}'
                                              : 'Sélectionner Date Début')
                                          : field['name'] == 'date_fin'
                                              ? (selectedDateFin != null
                                                  ? '${selectedDateFin!.day}/${selectedDateFin!.month}/${selectedDateFin!.year}'
                                                  : 'Sélectionner Date Fin')
                                              : (selectedDate != null
                                                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                                  : 'Sélectionner Date'),
                                      style: TextStyle(
                                          color: Colors.black87, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (field['type'] == 'image') {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(field['icon'],
                                      color: Colors.indigo[700], size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    field['label'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo[900],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (widget.title == 'Agences' &&
                                  selectedLogoPath != null &&
                                  selectedLogoPath!.isNotEmpty)
                                Stack(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: selectedLogoPath!
                                                .startsWith('http')
                                            ? CachedNetworkImage(
                                                imageUrl: selectedLogoPath!,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                                color: Colors
                                                                        .indigo[
                                                                    700])),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Center(
                                                        child: Icon(
                                                            MdiIcons
                                                                .alertCircle,
                                                            color: Colors
                                                                .redAccent,
                                                            size: 40)),
                                              )
                                            : Image.file(
                                                File(selectedLogoPath!),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Center(
                                                        child: Icon(
                                                            MdiIcons
                                                                .alertCircle,
                                                            color: Colors
                                                                .redAccent,
                                                            size: 40)),
                                              ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: IconButton(
                                        icon: Icon(MdiIcons.closeCircle,
                                            color: Colors.redAccent, size: 28),
                                        onPressed: () => setState(() {
                                          selectedLogoPath = null;
                                          formData['logo'] = null;
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              if (widget.title == 'Maisons' &&
                                  selectedPhotoPaths != null &&
                                  selectedPhotoPaths!.isNotEmpty) ...[
                                SizedBox(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: selectedPhotoPaths!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 6,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Image.file(
                                                  File(selectedPhotoPaths![
                                                      index]),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Center(
                                                          child: Icon(
                                                              MdiIcons
                                                                  .alertCircle,
                                                              color: Colors
                                                                  .redAccent,
                                                              size: 40)),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: IconButton(
                                                icon: Icon(MdiIcons.closeCircle,
                                                    color: Colors.redAccent,
                                                    size: 28),
                                                onPressed: () => setState(() {
                                                  selectedPhotoPaths!
                                                      .removeAt(index);
                                                  formData['photos'] =
                                                      selectedPhotoPaths;
                                                }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              if (widget.title == 'Agences')
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await _pickImage(isLogo: true);
                                    if (selectedLogoPath != null) {
                                      formData['logo'] = selectedLogoPath;
                                    }
                                  },
                                  icon: Icon(MdiIcons.imagePlus,
                                      color: Colors.white, size: 20),
                                  label: Text('Ajouter un logo',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo[700],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 14),
                                    elevation: 6,
                                    shadowColor: Colors.indigo[900],
                                  ),
                                ),
                              if (widget.title == 'Maisons')
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await _pickImage(isLogo: false);
                                    if (selectedPhotoPaths != null) {
                                      formData['photos'] = selectedPhotoPaths;
                                    }
                                  },
                                  icon: Icon(MdiIcons.imageMultiple,
                                      color: Colors.white, size: 20),
                                  label: Text('Ajouter des photos',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo[700],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 14),
                                    elevation: 6,
                                    shadowColor: Colors.indigo[900],
                                  ),
                                ),
                              if (widget.title == 'Photos')
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await _pickImage(isLogo: true);
                                    if (selectedLogoPath != null) {
                                      formData['photo'] = selectedLogoPath;
                                    }
                                  },
                                  icon: Icon(MdiIcons.imagePlus,
                                      color: Colors.white, size: 20),
                                  label: Text('Charger une photo',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo[700],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 14),
                                    elevation: 6,
                                    shadowColor: Colors.indigo[900],
                                  ),
                                ),
                            ],
                          );
                        } else if (field['name'] == 'etat_maison' &&
                            widget.title == 'Maisons') {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: field['label'],
                                labelStyle: TextStyle(
                                    color: Colors.indigo[900], fontSize: 16),
                                prefixIcon: Icon(MdiIcons.home,
                                    color: Colors.indigo[700], size: 24),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide:
                                      BorderSide(color: Colors.indigo[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                      color: Colors.indigo[900]!, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide:
                                      BorderSide(color: Colors.indigo[200]!),
                                ),
                                filled: true,
                                fillColor: Colors.indigo[50],
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                              ),
                              value: formData[field['name']]?.toString(),
                              items: ['Disponible', 'Occupé', 'En maintenance']
                                  .map((state) => DropdownMenuItem<String>(
                                        value: state,
                                        child: Text(state,
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16)),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  formData[field['name']] = value,
                              dropdownColor: Colors.white,
                              icon: Icon(MdiIcons.chevronDown,
                                  color: Colors.indigo[700], size: 24),
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 16),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          );
                        } else if (field['name'] == 'type_document' &&
                            widget.title == 'Locations') {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: field['label'],
                                labelStyle: TextStyle(
                                    color: Colors.indigo[900], fontSize: 16),
                                prefixIcon: Icon(MdiIcons.fileDocument,
                                    color: Colors.indigo[700], size: 24),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide:
                                      BorderSide(color: Colors.indigo[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                      color: Colors.indigo[900]!, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide:
                                      BorderSide(color: Colors.indigo[200]!),
                                ),
                                filled: true,
                                fillColor: Colors.indigo[50],
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                              ),
                              value: formData[field['name']]?.toString(),
                              items: ['CNI', 'Passeport', 'Permis de conduire']
                                  .map((docType) => DropdownMenuItem<String>(
                                        value: docType,
                                        child: Text(docType,
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16)),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  formData[field['name']] = value,
                              dropdownColor: Colors.white,
                              icon: Icon(MdiIcons.chevronDown,
                                  color: Colors.indigo[700], size: 24),
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 16),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: TextFormField(
                              initialValue:
                                  formData[field['name']]?.toString() ?? '',
                              readOnly: field['readOnly'] == true,
                              decoration: InputDecoration(
                                labelText: field['label'],
                                labelStyle: TextStyle(
                                    color: Colors.indigo[900], fontSize: 16),
                                prefixIcon: Icon(field['icon'] ?? MdiIcons.text,
                                    color: Colors.indigo[700], size: 24),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide:
                                      BorderSide(color: Colors.indigo[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                      color: Colors.indigo[900]!, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide:
                                      BorderSide(color: Colors.indigo[200]!),
                                ),
                                filled: true,
                                fillColor: Colors.indigo[50],
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                              ),
                              keyboardType: field['type'] == 'number'
                                  ? TextInputType.number
                                  : field['type'] == 'email'
                                      ? TextInputType.emailAddress
                                      : TextInputType.text,
                              onChanged: (value) => formData[field['name']] =
                                  field['type'] == 'number'
                                      ? num.tryParse(value) ?? 0
                                      : value,
                              validator: field['validator'] != null
                                  ? (value) => field['validator']!(value)
                                  : null,
                            ),
                          );
                        }
                      }).toList(),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                              shadowColor: Colors.grey[500],
                            ),
                            child: Text(
                              'Annuler',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 24),
                          ElevatedButton(
                            onPressed: () async {
                              bool? confirm = isEditing
                                  ? await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        title: Text(
                                          'Confirmer modification',
                                          style: TextStyle(
                                              color: Colors.indigo[900]),
                                        ),
                                        content: Text(
                                          'Voulez-vous modifier cet élément ?',
                                          style:
                                              TextStyle(color: Colors.black87),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text('Non',
                                                style: TextStyle(
                                                    color: Colors.grey[600])),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text('Oui',
                                                style: TextStyle(
                                                    color: Colors.indigo[900])),
                                          ),
                                        ],
                                      ),
                                    ).then((value) => value ?? false)
                                  : true;
                              if (confirm! &&
                                  _formKey.currentState!.validate()) {
                                try {
                                  if (isEditing) {
                                    await widget.service
                                        .update(formData['id'], formData);
                                  } else if (widget.title == 'Agences' &&
                                      selectedLogoPath != null) {
                                    await widget.service.createWithImage(
                                      formData,
                                      imagePath: selectedLogoPath,
                                      imageField: 'logo',
                                    );
                                  } else if (widget.title == 'Maisons' &&
                                      selectedPhotoPaths != null) {
                                    await widget.service.createWithImage(
                                      formData,
                                      imagePath: selectedPhotoPaths!.isNotEmpty
                                          ? selectedPhotoPaths![0]
                                          : null,
                                      imageField: 'photos',
                                    );
                                  } else {
                                    await widget.service.create(formData);
                                  }
                                  Navigator.pop(context);
                                  fetchItems();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${isEditing ? 'Modifié' : 'Ajouté'} avec succès'),
                                      backgroundColor: Colors.green[600],
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur: $e'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 6,
                              shadowColor: Colors.indigo[900],
                            ),
                            child: Text(
                              isEditing ? 'Modifier' : 'Ajouter',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cloturerLocation(int id, int maisonId) async {
    bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Clôturer location',
                    style: TextStyle(color: Colors.red[700])),
                content: Text('Voulez-vous clôturer cette location ?',
                    style: TextStyle(color: Colors.black87)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Non',
                          style: TextStyle(color: Colors.grey[600]))),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child:
                          Text('Oui', style: TextStyle(color: Colors.red[700])))
                ])).then((value) => value ?? false);
    if (confirm == true) {
      try {
        final locationService = LocationService();
        await locationService.cloturerLocation(id, maisonId);
        fetchItems();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Location clôturée avec succès'),
            backgroundColor: Colors.green[600]));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erreur: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  Widget _buildSidebarItem(IconData icon, String title, VoidCallback onTap,
      [bool isSelected = false]) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
            message: title,
            child: ListTile(
                leading: Icon(icon,
                    color: isSelected ? Colors.white : Colors.grey[300],
                    size: 26),
                title: Text(title,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16)),
                onTap: onTap,
                tileColor: isSelected ? Colors.teal[700] : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)))));
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
            decoration: BoxDecoration(color: Colors.teal[900], boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 10, offset: Offset(2, 0))
            ]),
            child: Column(
              children: [
                SizedBox(height: 20),
                ListTile(
                    leading: Icon(MdiIcons.menu, color: Colors.white),
                    title: Text('Menu',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18))),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSidebarItem(Icons.home, 'Accueil',
                            () => Navigator.pushNamed(context, Routes.home)),
                        _buildSidebarItem(Icons.view_agenda, 'Maisons',
                            () => Navigator.pushNamed(context, Routes.maisons)),
                        _buildSidebarItem(Icons.business, 'Agences',
                            () => Navigator.pushNamed(context, Routes.agences)),
                        _buildSidebarItem(
                            Icons.location_on,
                            'Locations',
                            () =>
                                Navigator.pushNamed(context, Routes.locations)),
                        _buildSidebarItem(
                            Icons.payment,
                            'Paiements',
                            () =>
                                Navigator.pushNamed(context, Routes.paiements)),
                        _buildSidebarItem(
                            Icons.warning,
                            'Pénalités',
                            () =>
                                Navigator.pushNamed(context, Routes.penalites)),
                        _buildSidebarItem(Icons.photo, 'Photos',
                            () => Navigator.pushNamed(context, Routes.photos)),
                        _buildSidebarItem(
                            Icons.settings,
                            'Paramètres',
                            () => Navigator.pushNamed(
                                context, Routes.parametres)),
                        _buildSidebarItem(widget.icon, widget.title,
                            () => setState(() {}), true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Colors.teal[600]!,
                                  Colors.teal[800]!
                                ]),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 4))
                                ]),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(widget.title,
                                      style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  IconButton(
                                      icon: Icon(Icons.refresh,
                                          color: Colors.white),
                                      onPressed: fetchItems)
                                ]),
                          ),
                          SizedBox(height: 20),
                          isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.teal[700]))
                              : errorMessage != null
                                  ? Center(
                                      child: Text(errorMessage!,
                                          style: TextStyle(
                                              color: Colors.red[700])))
                                  : items.isEmpty
                                      ? Center(
                                          child: Column(children: [
                                          SizedBox(height: 50),
                                          Icon(widget.icon,
                                              size: 80,
                                              color: Colors.grey[400]),
                                          SizedBox(height: 10),
                                          Text('Aucune donnée',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.grey[600]))
                                        ]))
                                      : SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            columnSpacing: 20,
                                            headingRowColor:
                                                MaterialStateColor.resolveWith(
                                                    (states) =>
                                                        Colors.teal[100]!),
                                            dataRowColor:
                                                MaterialStateColor.resolveWith(
                                                    (states) => Colors.white),
                                            border: TableBorder(
                                              horizontalInside: BorderSide(
                                                  color: Colors.grey[200]!),
                                              verticalInside: BorderSide(
                                                  color: Colors.grey[200]!),
                                            ),
                                            columns: [
                                              DataColumn(
                                                  label: Text('N°',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .teal[900]))),
                                              ...widget.fields
                                                  .where((field) => ![
                                                        'logo',
                                                        'photos'
                                                      ].contains(field['name']))
                                                  .map((field) => DataColumn(
                                                      label: Text(
                                                          field['label'],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .teal[900]))))
                                                  .toList(),
                                              DataColumn(
                                                  label: Text('Actions',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .teal[900]))),
                                            ],
                                            rows: items
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              final index = entry.key;
                                              final item = entry.value;
                                              return DataRow(
                                                cells: [
                                                  DataCell(Text('${index + 1}',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.black87))),
                                                  ...widget.fields
                                                      .where((field) => ![
                                                            'logo',
                                                            'photos'
                                                          ].contains(
                                                              field['name']))
                                                      .map((field) => DataCell(Text(
                                                          item[field['name']]
                                                                  ?.toString() ??
                                                              '',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black87))))
                                                      .toList(),
                                                  DataCell(Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                          icon: Icon(Icons.edit,
                                                              color: Colors
                                                                  .blue[700]),
                                                          onPressed: () =>
                                                              _showFormDialog(
                                                                  item: item)),
                                                      if (widget.title ==
                                                              'Locations' &&
                                                          item['active'] ==
                                                              true)
                                                        IconButton(
                                                          icon: Icon(
                                                              MdiIcons.closeBox,
                                                              color: Colors
                                                                  .orange[700]),
                                                          onPressed: () {
                                                            final id =
                                                                int.tryParse(item[
                                                                            'id']
                                                                        .toString()) ??
                                                                    0;
                                                            final maisonId =
                                                                int.tryParse(item[
                                                                            'maison_id']
                                                                        .toString()) ??
                                                                    0;
                                                            if (id == 0 ||
                                                                maisonId == 0) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                      'ID ou maison_id invalide pour la clôture'),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .redAccent,
                                                                ),
                                                              );
                                                              return;
                                                            }
                                                            _cloturerLocation(
                                                                id, maisonId);
                                                          },
                                                        ),
                                                      IconButton(
                                                        icon: Icon(Icons.delete,
                                                            color: Colors
                                                                .red[700]),
                                                        onPressed: () {
                                                          final id =
                                                              int.tryParse(item[
                                                                          'id']
                                                                      .toString()) ??
                                                                  0;
                                                          if (id == 0) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'ID invalide pour la suppression'),
                                                                backgroundColor:
                                                                    Colors
                                                                        .redAccent,
                                                              ),
                                                            );
                                                            return;
                                                          }
                                                          _deleteItem(id);
                                                        },
                                                      ),
                                                    ],
                                                  )),
                                                ],
                                                onSelectChanged: (selected) {
                                                  if (selected == true) {
                                                    setState(() {
                                                      selectedItem = item;
                                                    });
                                                  }
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () => _showFormDialog(),
                              icon: Icon(MdiIcons.plus,
                                  size: 20, color: Colors.white),
                              label: Text('Ajouter ${widget.title}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[700],
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 5,
                                  shadowColor: Colors.teal[900]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selectedItem != null)
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              'Détails de l\'${widget.title.toLowerCase()}',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.teal[700])),
                                          IconButton(
                                              icon: Icon(MdiIcons.close,
                                                  color: Colors.grey[700]),
                                              onPressed: () => setState(
                                                  () => selectedItem = null))
                                        ]),
                                    SizedBox(height: 10),
                                    ...widget.fields
                                        .where((field) => !['logo', 'photos']
                                            .contains(field['name']))
                                        .map((field) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${field['label']}: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.teal[900]),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      selectedItem![
                                                                  field['name']]
                                                              ?.toString() ??
                                                          '',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                    if (selectedItem!['logo'] != null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Logo:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.teal[900]),
                                          ),
                                          SizedBox(height: 5),
                                          Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 6,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: CachedNetworkImage(
                                                imageUrl: selectedItem!['logo'],
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                                color:
                                                                    Colors.teal[
                                                                        700])),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Center(
                                                        child: Icon(
                                                            MdiIcons
                                                                .alertCircle,
                                                            color: Colors
                                                                .redAccent,
                                                            size: 40)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (selectedItem!['photos'] != null &&
                                        (selectedItem!['photos'] as List)
                                            .isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Photos:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.teal[900]),
                                          ),
                                          SizedBox(height: 5),
                                          SizedBox(
                                            height: 120,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  (selectedItem!['photos']
                                                          as List)
                                                      .length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 12),
                                                  child: Container(
                                                    width: 120,
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black12,
                                                          blurRadius: 6,
                                                          offset: Offset(0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      child: CachedNetworkImage(
                                                        imageUrl: selectedItem![
                                                            'photos'][index],
                                                        fit: BoxFit.cover,
                                                        placeholder: (context,
                                                                url) =>
                                                            Center(
                                                                child: CircularProgressIndicator(
                                                                    color: Colors
                                                                            .teal[
                                                                        700])),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Center(
                                                                child: Icon(
                                                                    MdiIcons
                                                                        .alertCircle,
                                                                    color: Colors
                                                                        .redAccent,
                                                                    size: 40)),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
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
