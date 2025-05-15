import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/models/services/payment_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/constants/routes.dart';
import '../../data/services/payment_service.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/penalty_model.dart';
import '../../shared/themes/app_theme.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _paymentService = PaymentService();
  List<PaymentModel> _payments = [];
  List<PenaltyModel> _penalties = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0 pour paiements, 1 pour pénalités

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final payments = await _paymentService.fetchPayments();
      final penalties = await _paymentService.fetchPenalties();
      setState(() {
        _payments = payments;
        _penalties = penalties;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement : $e')),
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
        title: const Text('Paiements & Pénalités'),
        actions: [
          if (_selectedTab == 0)
            IconButton(
              icon: Icon(MdiIcons.plus),
              onPressed: () => Navigator.pushNamed(context, Routes.addPayment),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTab == 0
                          ? AppTheme.primaryColor
                          : Colors.grey[300],
                      foregroundColor:
                          _selectedTab == 0 ? Colors.white : AppTheme.textColor,
                    ),
                    child: const Text('Paiements'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTab == 1
                          ? AppTheme.primaryColor
                          : Colors.grey[300],
                      foregroundColor:
                          _selectedTab == 1 ? Colors.white : AppTheme.textColor,
                    ),
                    child: const Text('Pénalités'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedTab == 0
                    ? _buildPaymentsList()
                    : _buildPenaltiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList() {
    if (_payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.cash,
              size: 80,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun paiement trouvé',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(
              MdiIcons.cash,
              color: AppTheme.primaryColor,
            ),
            title: Text('Paiement #${payment.id}'),
            subtitle: Text(
              'Date: ${payment.date} • Montant: ${payment.amount} FCFA',
            ),
            trailing: Icon(
              MdiIcons.arrowRight,
              color: AppTheme.secondaryTextColor,
            ),
            onTap: () {
              // TODO: Naviguer vers les détails du paiement
            },
          ),
        );
      },
    );
  }

  Widget _buildPenaltiesList() {
    if (_penalties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.alert,
              size: 80,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune pénalité trouvée',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _penalties.length,
      itemBuilder: (context, index) {
        final penalty = _penalties[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(
              MdiIcons.alert,
              color: Colors.red,
            ),
            title: Text('Pénalité #${penalty.id}'),
            subtitle: Text(
              'Raison: ${penalty.reason} • Montant: ${penalty.amount} FCFA',
            ),
            trailing: Icon(
              MdiIcons.arrowRight,
              color: AppTheme.secondaryTextColor,
            ),
            onTap: () {
              // TODO: Naviguer vers les détails de la pénalité
            },
          ),
        );
      },
    );
  }
}
