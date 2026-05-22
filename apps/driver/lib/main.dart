import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_tokens/colors.dart';
import 'package:design_tokens/typography.dart';
import 'package:design_tokens/radii.dart';
import 'package:design_tokens/theme.dart';

void main() {
  runApp(const MyDriverApp());
}

class MyDriverApp extends StatelessWidget {
  const MyDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TastyLife Livreur',
      theme: TastyTheme.defaultTheme,
      debugShowCheckedModeBanner: false,
      home: const DriverMainRouter(),
    );
  }
}

// App Screens Routing System
enum DriverScreen {
  welcome,
  kycProgress,
  mainDashboard,
}

enum DeliveryStage {
  idle,
  offerReceived,
  headingToRestaurant,
  atRestaurant,
  headingToCustomer,
  validatingHandover,
  completed,
}

class DriverMainRouter extends StatefulWidget {
  const DriverMainRouter({super.key});

  @override
  State<DriverMainRouter> createState() => _DriverMainRouterState();
}

class _DriverMainRouterState extends State<DriverMainRouter> {
  DriverScreen _currentScreen = DriverScreen.welcome;
  DeliveryStage _deliveryStage = DeliveryStage.idle;
  
  // Shift & Earnings States
  bool _isOnline = false;
  int _completedDeliveries = 6;
  int _shiftEarnings = 18500;
  final double _averageRating = 4.9;

  // Active Job states
  final String _orderId = '#TL-8842';
  final String _restaurantName = 'Chez Poulet d\'Or';
  final String _restaurantLocation = 'Kintambo, Kinshasa';
  final String _customerName = 'Jérôme K.';
  final String _customerLocation = 'Av. Kasa-Vubu, face Pharmacie Bolingo';
  final int _orderPayout = 2500;

  // Security code inputs
  String _enteredSecurityCode = '';
  bool _codeError = false;

  void _navigateTo(DriverScreen screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  void _triggerSimulatedOffer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isOnline && _deliveryStage == DeliveryStage.idle) {
        setState(() {
          _deliveryStage = DeliveryStage.offerReceived;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
      case DriverScreen.welcome:
        return _buildWelcomeScreen();
      case DriverScreen.kycProgress:
        return _buildKycProgressScreen();
      case DriverScreen.mainDashboard:
        return _buildDashboardScreen();
    }
  }

  // --- WELCOME SCREEN ---
  Widget _buildWelcomeScreen() {
    return Scaffold(
      backgroundColor: TastyColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),
              Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: TastyColors.brand.withOpacity(0.1),
                      borderRadius: TastyRadii.cardRadius,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.delivery_dining,
                        size: 48,
                        color: TastyColors.brand,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'TASTY LIFE',
                    style: TextStyle(
                      fontFamily: TastyTypography.logoFontFamily,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: TastyColors.brand,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gagnez avec TastyLife · Livreur Kinshasa',
                    style: TastyTypography.title.copyWith(
                      color: TastyColors.ink.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Rejoignez la plus grande flotte de livraison à Kinshasa. Paiements instantanés, horaires flexibles.',
                    textAlign: TextAlign.center,
                    style: TastyTypography.bodyLg,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _navigateTo(DriverScreen.kycProgress),
                      child: const Text('Se connecter en tant que livreur'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- KYC PROGRESS / APPLICATION STATUS ---
  Widget _buildKycProgressScreen() {
    return Scaffold(
      backgroundColor: TastyColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: TastyColors.ink),
                    onPressed: () => _navigateTo(DriverScreen.welcome),
                  ),
                  const SizedBox(height: 20),
                  const Text('Statut de l\'application', style: TastyTypography.headline),
                  const SizedBox(height: 6),
                  Text(
                    'Dernière mise à jour : Il y a 5 min',
                    style: TastyTypography.caption.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),
                  
                  // Setup checklist progress items
                  _buildChecklistItem('Permis de conduire', 'Validé par l\'équipe ops', true),
                  _buildChecklistItem('Carte d\'identité nationale', 'Validé par SmileID API', true),
                  _buildChecklistItem('Certificat d\'immatriculation moto', 'Validé par l\'équipe ops', true),
                  _buildChecklistItem('Examen de sécurité routière', 'Complété le 18 mai', true),
                  
                  const Divider(height: 40),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: TastyRadii.cardRadius,
                      border: Border.all(color: Colors.green[100]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: TastyColors.success, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dossier Approved !', style: TastyTypography.title.copyWith(color: Colors.green[800])),
                              Text('Votre compte livreur est prêt. Vous pouvez commencer à rouler.', style: TastyTypography.caption.copyWith(color: Colors.green[700])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _navigateTo(DriverScreen.mainDashboard),
                  child: const Text('Accéder au tableau de bord'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String title, String subtitle, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? TastyColors.success : Colors.grey[300],
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TastyTypography.title),
                Text(subtitle, style: TastyTypography.caption.copyWith(color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- DRIVER DASHBOARD ---
  Widget _buildDashboardScreen() {
    return Scaffold(
      backgroundColor: TastyColors.paper,
      body: Stack(
        children: [
          // Shift status bar
          Column(
            children: [
              _buildShiftStatusBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DASHBOARD DU JOUR', style: TastyTypography.labelSm),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard('Chiffre d\'Affaire', '$_shiftEarnings FC', Icons.monetization_on)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildMetricCard('Livraisons', '$_completedDeliveries', Icons.sports_motorsports)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildMetricRowCard('Note moyenne du shift', '★ $_averageRating', 'Sur les 6 dernières courses de ce shift', Icons.star),
                      
                      const SizedBox(height: 24),
                      
                      if (_deliveryStage == DeliveryStage.idle) ...[
                        const Text('STATUT DU SERVICE', style: TastyTypography.labelSm),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: TastyRadii.cardRadius,
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _isOnline ? Icons.radar : Icons.power_settings_new,
                                size: 48,
                                color: _isOnline ? TastyColors.brand : Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isOnline
                                    ? 'Recherche active de commandes...'
                                    : 'Vous êtes hors ligne',
                                style: TastyTypography.headline,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _isOnline
                                    ? 'Restez dans la zone de Kintambo pour recevoir des offres rapidement.'
                                    : 'Passez en ligne pour commencer à recevoir des livraisons de nourriture.',
                                textAlign: TextAlign.center,
                                style: TastyTypography.caption.copyWith(color: Colors.grey[500]),
                              ),
                              if (_isOnline) ...[
                                const SizedBox(height: 20),
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: TastyColors.brand, strokeWidth: 2),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      // Accepted order tracking card
                      if (_deliveryStage != DeliveryStage.idle && _deliveryStage != DeliveryStage.offerReceived)
                        _buildActiveDeliveryProcessCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Pop-up Simulated Ride Request Notification
          if (_deliveryStage == DeliveryStage.offerReceived)
            _buildRideRequestOverlay(),
        ],
      ),
    );
  }

  Widget _buildShiftStatusBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _isOnline ? TastyColors.success : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isOnline ? 'EN LIGNE' : 'HORS LIGNE',
                style: TastyTypography.title.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Switch(
            value: _isOnline,
            activeColor: TastyColors.brand,
            onChanged: (val) {
              setState(() {
                _isOnline = val;
                if (!val) {
                  _deliveryStage = DeliveryStage.idle;
                }
              });
              if (val) {
                _triggerSimulatedOffer();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: TastyRadii.cardRadius,
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TastyTypography.caption.copyWith(color: Colors.grey[500])),
              Icon(icon, color: TastyColors.brand, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TastyTypography.headline.copyWith(color: TastyColors.brand)),
        ],
      ),
    );
  }

  Widget _buildMetricRowCard(String title, String value, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: TastyRadii.cardRadius,
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: TastyColors.brand.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(icon, color: TastyColors.brand, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TastyTypography.title),
                Text(subtitle, style: TastyTypography.caption.copyWith(color: Colors.grey[500])),
              ],
            ),
          ),
          Text(value, style: TastyTypography.headline.copyWith(color: TastyColors.brand)),
        ],
      ),
    );
  }

  // --- ACTIVE RIDE REQUEST POPUP OVERLAY ---
  Widget _buildRideRequestOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: TastyColors.paper,
            borderRadius: TastyRadii.cardRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber[100], borderRadius: TastyRadii.badgeRadius),
                    child: const Text('NOUVELLE OFFRE', style: TextStyle(fontSize: 10, color: TastyColors.brand, fontWeight: FontWeight.bold)),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.timer, size: 14, color: Colors.red),
                      SizedBox(width: 4),
                      Text('12s restant', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('COURSE DISPONIBLE', style: TastyTypography.labelSm),
              Text(
                '$_orderPayout FC',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: TastyColors.brand),
              ),
              const Divider(height: 24),
              _buildLocationTextRow('RESTAURANT', _restaurantName, _restaurantLocation, isResto: true),
              const SizedBox(height: 16),
              _buildLocationTextRow('CLIENT', _customerName, _customerLocation, isResto: false),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _deliveryStage = DeliveryStage.idle;
                        });
                        _triggerSimulatedOffer();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Refuser', style: TextStyle(color: TastyColors.ink)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _deliveryStage = DeliveryStage.headingToRestaurant;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Accepter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationTextRow(String label, String name, String subtitle, {required bool isResto}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isResto ? Icons.storefront : Icons.location_on,
          color: isResto ? TastyColors.brand : TastyColors.success,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TastyTypography.labelSm.copyWith(color: Colors.grey[500])),
              Text(name, style: TastyTypography.title.copyWith(fontWeight: FontWeight.bold)),
              Text(subtitle, style: TastyTypography.caption.copyWith(color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  // --- ACTIVE JOB PROCESS CARD ---
  Widget _buildActiveDeliveryProcessCard() {
    String stepTitle = '';
    String stepInstructions = '';
    String buttonText = '';
    VoidCallback onButtonTap = () {};

    switch (_deliveryStage) {
      case DeliveryStage.headingToRestaurant:
        stepTitle = 'Aller chez Poulet d\'Or';
        stepInstructions = 'Récupérer la commande $_orderId. Emballage scellé requis.';
        buttonText = 'Arrivé au restaurant';
        onButtonTap = () {
          setState(() {
            _deliveryStage = DeliveryStage.atRestaurant;
          });
        };
        break;
      case DeliveryStage.atRestaurant:
        stepTitle = 'Vérifier la commande en cuisine';
        stepInstructions = '1x Poulet Moambe, 1x Bissap fraîche.\nConfirmez la récupération.';
        buttonText = 'Confirmer la récupération';
        onButtonTap = () {
          setState(() {
            _deliveryStage = DeliveryStage.headingToCustomer;
          });
        };
        break;
      case DeliveryStage.headingToCustomer:
        stepTitle = 'Livrer à Jérôme K.';
        stepInstructions = 'Av. Kasa-Vubu, face Pharmacie Bolingo.\nNote client : "Parcelle 14, 3e étage".';
        buttonText = 'Arrivé chez le client';
        onButtonTap = () {
          setState(() {
            _deliveryStage = DeliveryStage.validatingHandover;
          });
        };
        break;
      case DeliveryStage.validatingHandover:
        stepTitle = 'Valider avec le code client';
        stepInstructions = 'Demandez au client son code de sécurité à 4 chiffres affiché sur son appli.';
        buttonText = 'Valider le code';
        onButtonTap = () {
          _validateHandoverCode();
        };
        break;
      default:
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: TastyRadii.cardRadius,
        border: Border.all(color: TastyColors.brand, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LIVRAISON EN COURS',
                style: TastyTypography.labelSm.copyWith(color: TastyColors.brand),
              ),
              Text(
                _orderId,
                style: TastyTypography.title.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(stepTitle, style: TastyTypography.headline),
          const SizedBox(height: 6),
          Text(stepInstructions, style: TastyTypography.bodyLg.copyWith(color: Colors.grey[600])),
          
          if (_deliveryStage == DeliveryStage.validatingHandover) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: TastyRadii.cardRadius,
                border: Border.all(color: _codeError ? Colors.red : Colors.grey[200]!),
              ),
              child: TextField(
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 12),
                decoration: const InputDecoration(
                  hintText: 'CODE',
                  border: InputBorder.none,
                  counterText: '',
                ),
                onChanged: (val) {
                  setState(() {
                    _enteredSecurityCode = val;
                    _codeError = false;
                  });
                },
              ),
            ),
            if (_codeError)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 14),
                    const SizedBox(width: 4),
                    Text('Code erroné (essayez 4821)', style: TastyTypography.caption.copyWith(color: Colors.red)),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text('Le code du client dans son appli est 4821.', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ),
          ],
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onButtonTap,
              child: Text(buttonText),
            ),
          ),
          
          if (_deliveryStage == DeliveryStage.headingToCustomer) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone, color: TastyColors.ink),
                    label: const Text('Appeler client', style: TextStyle(color: TastyColors.ink)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _validateHandoverCode() {
    if (_enteredSecurityCode == '4821') {
      setState(() {
        _completedDeliveries += 1;
        _shiftEarnings += _orderPayout;
        _deliveryStage = DeliveryStage.idle;
        _enteredSecurityCode = '';
        _codeError = false;
      });
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: TastyRadii.cardRadius),
            backgroundColor: TastyColors.paper,
            title: const Row(
              children: [
                Icon(Icons.verified, color: TastyColors.success),
                SizedBox(width: 10),
                Text('Course Complétée !', style: TastyTypography.headline),
              ],
            ),
            content: const Text(
              'Code de sécurité correct ! Le sac a été remis à Jérôme K. Votre portefeuille livreur a été crédité de +2 500 FC.',
              style: TastyTypography.bodyLg,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _triggerSimulatedOffer();
                },
                child: const Text('Continuer le service', style: TextStyle(color: TastyColors.brand, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _codeError = true;
      });
    }
  }
}
