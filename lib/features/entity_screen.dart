import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/data/services/base_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  final Map<String, dynamic> _dropdownValues = {};
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  List<dynamic> communes = [];
  List<dynamic> agences = [];
  List<dynamic> documents = [];
  List<dynamic> maisons = [];
  List<dynamic> locations = [];
  List<dynamic> commodites = [];

  dynamic _editingItem;

  @override
  void initState() {
    super.initState();
    _fetchDependencies();
    _initializeControllers();
    _fetchItems();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _fetchDependencies() async {
    try {
      if (widget.entityName.toLowerCase() == 'maison' ||
          widget.entityName.toLowerCase() == 'commodite-maison') {
        final communeResponse =
            await http.get(Uri.parse('http://127.0.0.1:8000/communes/'));
        final agenceResponse =
            await http.get(Uri.parse('http://127.0.0.1:8000/agences/'));
        final communeData = jsonDecode(communeResponse.body);
        final agenceData = jsonDecode(agenceResponse.body);
        setState(() {
          communes = communeData is Map && communeData.containsKey('results')
              ? communeData['results'] as List<dynamic>
              : communeData as List<dynamic>;
          agences = agenceData is Map && agenceData.containsKey('results')
              ? agenceData['results'] as List<dynamic>
              : agenceData as List<dynamic>;
        });
      }
      if (widget.entityName.toLowerCase() == 'location') {
        final maisonResponse =
            await http.get(Uri.parse('http://127.0.0.1:8000/maisons/'));
        final documentResponse =
            await http.get(Uri.parse('http://127.0.0.1:8000/documents/'));
        final maisonData = jsonDecode(maisonResponse.body);
        final documentData = jsonDecode(documentResponse.body);
        setState(() {
          maisons = maisonData is Map && maisonData.containsKey('results')
              ? maisonData['results'] as List<dynamic>
              : maisonData as List<dynamic>;
          documents = documentData is Map && documentData.containsKey('results')
              ? documentData['results'] as List<dynamic>
              : documentData as List<dynamic>;
        });
      }
      if (widget.entityName.toLowerCase() == 'paiement' ||
          widget.entityName.toLowerCase() == 'penalite') {
        final locationResponse =
            await http.get(Uri.parse('http://127.0.0.1:8000/locations/'));
        final locationData = jsonDecode(locationResponse.body);
        setState(() {
          locations = locationData is Map && locationData.containsKey('results')
              ? locationData['results'] as List<dynamic>
              : locationData as List<dynamic>;
        });
      }
      if (widget.entityName.toLowerCase() == 'commodite-maison') {
        final commoditeResponse =
            await http.get(Uri.parse('http://127.0.0.1:8000/commodites/'));
        final commoditeData = jsonDecode(commoditeResponse.body);
        setState(() {
          commodites =
              commoditeData is Map && commoditeData.containsKey('results')
                  ? commoditeData['results'] as List<dynamic>
                  : commoditeData as List<dynamic>;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des dépendances: $e';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _initializeControllers() {
    switch (widget.entityName.toLowerCase()) {
      case 'maison':
        _controllers['immat'] = TextEditingController();
        _controllers['loyer'] = TextEditingController();
        _controllers['telDemarceur'] = TextEditingController();
        _controllers['quartier'] = TextEditingController();
        _controllers['section'] = TextEditingController();
        _controllers['lot'] = TextEditingController();
        _controllers['parcelle'] = TextEditingController();
        _controllers['degLat'] = TextEditingController();
        _controllers['minLat'] = TextEditingController();
        _controllers['secLat'] = TextEditingController();
        _controllers['emisphere'] = TextEditingController();
        _controllers['degLong'] = TextEditingController();
        _controllers['minLong'] = TextEditingController();
        _controllers['secLong'] = TextEditingController();
        _controllers['fuseau'] = TextEditingController();
        _controllers['description'] = TextEditingController();
        _controllers['etat'] = TextEditingController();
        _dropdownValues['commune'] = null;
        _dropdownValues['agence'] = null;
        break;
      case 'agence':
        _controllers['nom'] = TextEditingController();
        _controllers['sigle'] = TextEditingController();
        _controllers['telephone'] = TextEditingController();
        _controllers['whatsapp'] = TextEditingController();
        _controllers['email'] = TextEditingController();
        _controllers['numeroCompte'] = TextEditingController();
        _controllers['ifu'] = TextEditingController();
        break;
      case 'location':
        _controllers['dateEntre'] = TextEditingController();
        _controllers['dateSortie'] = TextEditingController();
        _controllers['nomClient'] = TextEditingController();
        _controllers['prenomClient'] = TextEditingController();
        _controllers['telephoneClient'] = TextEditingController();
        _controllers['numeroDocument'] = TextEditingController();
        _controllers['dateEtabli'] = TextEditingController();
        _controllers['dateExpi'] = TextEditingController();
        _dropdownValues['maison'] = null;
        _dropdownValues['typeDocument'] = null;
        break;
      case 'paiement':
        _controllers['datePaiement'] = TextEditingController();
        _controllers['numeroFacture'] = TextEditingController();
        _controllers['montant'] = TextEditingController();
        _dropdownValues['location'] = null;
        break;
      case 'penalite':
        _controllers['montant'] = TextEditingController();
        _dropdownValues['route'] = null;
        break;
      case 'document':
        _controllers['nom'] = TextEditingController();
        break;
      case 'commune':
        _controllers['nom'] = TextEditingController();
        break;
      case 'commodite':
        _controllers['nom'] = TextEditingController();
        break;
      case 'commodite-maison':
        _controllers['nombre'] = TextEditingController();
        _dropdownValues['commodite'] = null;
        _dropdownValues['maison'] = null;
        break;
      case 'photo':
        _controllers['libelle'] = TextEditingController();
        _dropdownValues['maison'] = null;
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
      _dropdownValues.forEach((key, value) {
        _dropdownValues[key] = item[key];
      });
      _imagePath = null;
    } else {
      _editingItem = null;
      _controllers.forEach((_, controller) => controller.clear());
      _dropdownValues.forEach((key, _) => _dropdownValues[key] = null);
      _imagePath = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item == null
              ? 'Ajouter un ${widget.entityName}'
              : 'Modifier un ${widget.entityName}',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
        ),
        content: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._controllers.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: entry.value,
                        builder: (context, value, child) {
                          final isInvalid =
                              _validateField(entry.key, value.text);
                          return TextField(
                            controller: entry.value,
                            keyboardType: _getKeyboardType(entry.key),
                            decoration: InputDecoration(
                              labelText: entry.key,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorText: isInvalid &&
                                      _shouldShowError(entry.key, value.text)
                                  ? 'Champ invalide ou requis'
                                  : null,
                              errorStyle: const TextStyle(color: Colors.grey),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                  if (widget.entityName.toLowerCase() == 'agence' ||
                      widget.entityName.toLowerCase() == 'photo')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Sélectionner une image'),
                          ),
                          if (_imagePath != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Image.file(
                                File(_imagePath!),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (widget.entityName.toLowerCase() == 'photo' &&
                              _imagePath == null &&
                              _editingItem == null)
                            const Text(
                              'Veuillez sélectionner une image',
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  if (_dropdownValues.containsKey('commune'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ValueListenableBuilder<int?>(
                        valueListenable:
                            ValueNotifier(_dropdownValues['commune']),
                        builder: (context, value, child) {
                          final isInvalid =
                              value == null && _isDropdownRequired();
                          return DropdownButtonFormField<int>(
                            value: value,
                            decoration: InputDecoration(
                              labelText: 'Commune',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorText: isInvalid &&
                                      _shouldShowError(
                                          'commune', value?.toString() ?? '')
                                  ? 'Champ requis'
                                  : null,
                              errorStyle: const TextStyle(color: Colors.grey),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items:
                                communes.map<DropdownMenuItem<int>>((commune) {
                              return DropdownMenuItem<int>(
                                value: commune['id'],
                                child: Text(commune['nom']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _dropdownValues['commune'] = value;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  if (_dropdownValues.containsKey('agence'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ValueListenableBuilder<int?>(
                        valueListenable:
                            ValueNotifier(_dropdownValues['agence']),
                        builder: (context, value, child) {
                          final isInvalid =
                              value == null && _isDropdownRequired();
                          return DropdownButtonFormField<int>(
                            value: value,
                            decoration: InputDecoration(
                              labelText: 'Agence',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorText: isInvalid &&
                                      _shouldShowError(
                                          'agence', value?.toString() ?? '')
                                  ? 'Champ requis'
                                  : null,
                              errorStyle: const TextStyle(color: Colors.grey),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: agences.map<DropdownMenuItem<int>>((agence) {
                              return DropdownMenuItem<int>(
                                value: agence['id'],
                                child: Text(agence['nom']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _dropdownValues['agence'] = value;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  if (_dropdownValues.containsKey('maison'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ValueListenableBuilder<int?>(
                        valueListenable:
                            ValueNotifier(_dropdownValues['maison']),
                        builder: (context, value, child) {
                          final isInvalid =
                              value == null && _isDropdownRequired();
                          return DropdownButtonFormField<int>(
                            value: value,
                            decoration: InputDecoration(
                              labelText: 'Maison',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorText: isInvalid &&
                                      _shouldShowError(
                                          'maison', value?.toString() ?? '')
                                  ? 'Champ requis'
                                  : null,
                              errorStyle: const TextStyle(color: Colors.grey),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: maisons.map<DropdownMenuItem<int>>((maison) {
                              return DropdownMenuItem<int>(
                                value: maison['id'],
                                child: Text(maison['immat']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _dropdownValues['maison'] = value;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  if (_dropdownValues.containsKey('typeDocument'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ValueListenableBuilder<int?>(
                        valueListenable:
                            ValueNotifier(_dropdownValues['typeDocument']),
                        builder: (context, value, child) {
                          final isInvalid =
                              value == null && _isDropdownRequired();
                          return DropdownButtonFormField<int>(
                            value: value,
                            decoration: InputDecoration(
                              labelText: 'Type de Document',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorText: isInvalid &&
                                      _shouldShowError('typeDocument',
                                          value?.toString() ?? '')
                                  ? 'Champ requis'
                                  : null,
                              errorStyle: const TextStyle(color: Colors.grey),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: documents
                                .map<DropdownMenuItem<int>>((document) {
                              return DropdownMenuItem<int>(
                                value: document['id'],
                                child: Text(document['nom']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _dropdownValues['typeDocument'] = value;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  if (_dropdownValues.containsKey('location') ||
                      _dropdownValues.containsKey('route'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ValueListenableBuilder<int?>(
                        valueListenable: ValueNotifier(
                            _dropdownValues['location'] ??
                                _dropdownValues['route']),
                        builder: (context, value, child) {
                          final isInvalid =
                              (value == null) && _isDropdownRequired();
                          return DropdownButtonFormField<int>(
                            value: value,
                            decoration: InputDecoration(
                              labelText: 'Location',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorText: isInvalid &&
                                      _shouldShowError(
                                          'location', value?.toString() ?? '')
                                  ? 'Champ requis'
                                  : null,
                              errorStyle: const TextStyle(color: Colors.grey),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: locations
                                .map<DropdownMenuItem<int>>((location) {
                              return DropdownMenuItem<int>(
                                value: location['id'],
                                child: Text('Location #${location['id']}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                if (_dropdownValues.containsKey('location')) {
                                  _dropdownValues['location'] = value;
                                } else {
                                  _dropdownValues['route'] = value;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  if (_dropdownValues.containsKey('commodite'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ValueListenableBuilder<int?>(
                        valueListenable:
                            ValueNotifier(_dropdownValues['commodite']),
                        builder: (context, value, child) {
                          final isInvalid =
                              value == null && _isDropdownRequired();
                          return DropdownButtonFormField<int>(
                            value: value,
                            decoration: InputDecoration(
                              labelText: 'Commodité',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        isInvalid ? Colors.grey : Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorText: isInvalid &&
                                      _shouldShowError(
                                          'commodite', value?.toString() ?? '')
                                  ? 'Champ requis'
                                  : null,
                              errorStyle: const TextStyle(color: Colors.grey),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: commodites
                                .map<DropdownMenuItem<int>>((commodite) {
                              return DropdownMenuItem<int>(
                                value: commodite['id'],
                                child: Text(commodite['nom']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _dropdownValues['commodite'] = value;
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.brown)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_controllers.entries.any(
                      (entry) => _validateField(entry.key, entry.value.text)) ||
                  _dropdownValues.values
                      .any((value) => value == null && _isDropdownRequired()) ||
                  (widget.entityName.toLowerCase() == 'photo' &&
                      _imagePath == null &&
                      _editingItem == null)) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Veuillez corriger les champs invalides')),
                );
                return;
              }

              final data = _formatData();
              if (_editingItem != null) {
                final confirm = await _showConfirmationDialog(
                  title: 'Confirmer la modification',
                  content: 'Êtes-vous sûr de vouloir modifier cet élément ?',
                );
                if (!confirm) return;
              }
              try {
                if (_editingItem == null) {
                  if (widget.entityName.toLowerCase() == 'agence' ||
                      widget.entityName.toLowerCase() == 'photo') {
                    await widget.service.createWithImage(
                      data,
                      imagePath: _imagePath,
                      imageField: widget.entityName.toLowerCase() == 'agence'
                          ? 'logo'
                          : 'donnee',
                    );
                  } else {
                    await widget.service.create(data);
                  }
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(item == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  bool _isDropdownRequired() {
    return widget.entityName.toLowerCase() != 'location' ||
        _dropdownValues['typeDocument'] != null;
  }

  Map<String, dynamic> _formatData() {
    final data = <String, dynamic>{};
    _controllers.forEach((key, controller) {
      final value = controller.text;
      if (value.isEmpty) return;
      if (key == 'loyer' ||
          key == 'lot' ||
          key == 'parcelle' ||
          key == 'degLat' ||
          key == 'minLat' ||
          key == 'degLong' ||
          key == 'minLong' ||
          key == 'montant' ||
          key == 'nombre') {
        data[key] = int.tryParse(value) ?? 0;
      } else if (key == 'secLat' || key == 'secLong') {
        data[key] = double.tryParse(value) ?? 0.0;
      } else {
        data[key] = value;
      }
    });
    _dropdownValues.forEach((key, value) {
      if (value != null) data[key] = value;
    });
    return data;
  }

  TextInputType _getKeyboardType(String field) {
    if (field == 'loyer' ||
        field == 'lot' ||
        field == 'parcelle' ||
        field == 'degLat' ||
        field == 'minLat' ||
        field == 'degLong' ||
        field == 'minLong' ||
        field == 'montant' ||
        field == 'nombre') {
      return TextInputType.number;
    }
    if (field == 'secLat' || field == 'secLong') {
      return TextInputType.numberWithOptions(decimal: true);
    }
    if (field.contains('date')) {
      return TextInputType.datetime;
    }
    if (field == 'telephone' || field == 'telephoneClient') {
      return TextInputType.phone;
    }
    if (field == 'email') {
      return TextInputType.emailAddress;
    }
    return TextInputType.text;
  }

  bool _validateField(String field, String value) {
    if (value.isEmpty) {
      if (field == 'telDemarceur' ||
          field == 'section' ||
          field == 'lot' ||
          field == 'parcelle' ||
          field == 'description' ||
          field == 'sigle' ||
          field == 'whatsapp' ||
          field == 'email' ||
          field == 'numeroCompte' ||
          field == 'ifu' ||
          field == 'dateSortie' ||
          field == 'numeroFacture' ||
          field == 'libelle') {
        return false;
      }
      return true;
    }
    if (field == 'loyer' ||
        field == 'lot' ||
        field == 'parcelle' ||
        field == 'degLat' ||
        field == 'minLat' ||
        field == 'degLong' ||
        field == 'minLong' ||
        field == 'montant' ||
        field == 'nombre') {
      return int.tryParse(value) == null;
    }
    if (field == 'secLat' || field == 'secLong') {
      return double.tryParse(value) == null;
    }
    if (field == 'emisphere' || field == 'fuseau') {
      return value.length != 1;
    }
    return false;
  }

  bool _shouldShowError(String field, String value) {
    // Afficher l'erreur uniquement si le champ est requis/invalide et que l'utilisateur tente de soumettre
    return _validateField(field, value) && _isFieldRequired(field);
  }

  bool _isFieldRequired(String field) {
    // Définir quels champs sont requis (à adapter selon vos besoins)
    final requiredFields = {
      'maison': ['immat', 'loyer', 'commune', 'agence'],
      'agence': ['nom', 'telephone'],
      'location': ['dateEntre', 'maison'],
      'paiement': ['datePaiement', 'montant', 'location'],
      'penalite': ['montant'],
      'document': ['nom'],
      'commune': ['nom'],
      'commodite': ['nom'],
      'commodite-maison': ['nombre', 'commodite', 'maison'],
      'photo': ['libelle', 'maison'],
    };
    return requiredFields[widget.entityName.toLowerCase()]?.contains(field) ??
        false;
  }

  Future<bool> _showConfirmationDialog(
      {required String title, required String content}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title, style: const TextStyle(color: Colors.brown)),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler',
                    style: TextStyle(color: Colors.brown)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white),
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
        title: Text('${widget.entityName} #${item['id']}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.brown)),
        content: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(color: Colors.brown)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddEditDialog(item: item);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown, foregroundColor: Colors.white),
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
        title: Text(
          widget.title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _getEntityColor(widget.entityName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchItems,
            tooltip: 'Rafraîchir',
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
                        style: const TextStyle(color: Colors.grey)))
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.brown,
        tooltip: 'Ajouter un ${widget.entityName}',
        child: Icon(MdiIcons.plusCircle, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
