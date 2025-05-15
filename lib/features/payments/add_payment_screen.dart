import 'package:flutter/material.dart';
import 'package:gestion_immo/data/models/services/payment_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../data/models/payment_model.dart';
import '../../data/services/payment_service.dart';
import '../../shared/themes/app_theme.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  _AddPaymentScreenState createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationIdController = TextEditingController();
  final _paymentService = PaymentService();
  bool _isLoading = false;

  void _addPayment() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final payment = PaymentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: double.parse(_amountController.text),
        date: _dateController.text,
        locationId: _locationIdController.text,
      );
      await _paymentService.addPayment(payment);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un paiement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _amountController,
                label: 'Montant (FCFA)',
                keyboardType: TextInputType.number,
                icon: MdiIcons.cash,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _dateController,
                label: 'Date (YYYY-MM-DD)',
                icon: MdiIcons.calendar,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _locationIdController,
                label: 'ID de la location',
                icon: MdiIcons.contrast,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Ajouter',
                icon: MdiIcons.plus,
                onPressed: _addPayment,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
