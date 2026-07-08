import 'dart:async';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/cart_controller.dart';
import 'chat_with_driver_screen.dart';
import 'rate_experience_screen.dart';

/// The active stages of simulated delivery progression.
enum DeliveryStage {
  placed,
  preparing,
  outForDelivery,
  arrived;

  String get label {
    switch (this) {
      case DeliveryStage.placed:
        return 'Order Placed';
      case DeliveryStage.preparing:
        return 'Preparing Food';
      case DeliveryStage.outForDelivery:
        return 'Out for Delivery';
      case DeliveryStage.arrived:
        return 'Driver Arrived';
    }
  }

  String get description {
    switch (this) {
      case DeliveryStage.placed:
        return 'The kitchen is accepting your order...';
      case DeliveryStage.preparing:
        return 'Chef is preparing your hot meal...';
      case DeliveryStage.outForDelivery:
        return 'Rider is on the way to your location!';
      case DeliveryStage.arrived:
        return 'Rider is outside! Meet him at the lobby.';
    }
  }
}

/// A fully animated, interactive, demo-ready live tracking screen that acts
/// like a real production delivery experience for clients and stakeholders.
class LiveOrderTrackingScreen extends StatefulWidget {
  const LiveOrderTrackingScreen({super.key});
  @override
  State<LiveOrderTrackingScreen> createState() => _LiveOrderTrackingScreenState();
}

class _LiveOrderTrackingScreenState extends State<LiveOrderTrackingScreen> {
  // The simulation timer + progress + stage now live in CartController so
  // they survive when the customer backs out of this screen. This widget
  // is now a thin read-only viewer that drives its visuals from the
  // controller via ListenableBuilder. The previous local-state version
  // would restart at 0.0 every time the screen remounted.

  // Used by the screen to detect a stage transition so the in-screen
  // banner can slide down only on a real change, not on remount.
  String _prevStageObserved = '';

  // --- Notification Banner State ---
  bool _showNotification = false;
  String _notifTitle = '';
  String _notifMsg = '';
  IconData _notifIcon = Icons.notifications;

  // --- Dev Panel Controller State ---
  bool _devPanelOpen = false;

  // --- Voice Call Screen Overlay State ---
  bool _activeCall = false;
  int _callDuration = 0;
  Timer? _callTimer;
  Timer? _pulseTimer;
  double _pulseVal = 0.0;
  bool _isMuted = false;
  bool _isSpeaker = false;

  ActiveOrder? get _order => CartController.instance.activeOrder;

  double get _simProgress => CartController.instance.simProgress;
  DeliveryStage get _stage {
    switch (CartController.instance.simStage) {
      case 'preparing':
        return DeliveryStage.preparing;
      case 'outForDelivery':
        return DeliveryStage.outForDelivery;
      case 'arrived':
        return DeliveryStage.arrived;
      default:
        return DeliveryStage.placed;
    }
  }

  // --- Street Path Vertices (Alignment Space) ---
  final List<Alignment> _routePoints = const [
    Alignment(0.0, -0.55),   // Restaurant (top center)
    Alignment(-0.45, -0.3),  // Street turn 1
    Alignment(0.35, -0.05),  // Street turn 2
    Alignment(-0.25, 0.25),  // Street turn 3
    Alignment(0.0, 0.55),    // Customer Home (bottom center)
  ];

  @override
  void initState() {
    super.initState();
    _prevStageObserved = CartController.instance.simStage;
    CartController.instance.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    final stage = CartController.instance.simStage;
    if (stage != _prevStageObserved) {
      _prevStageObserved = stage;
      _bannerForStage(stage);
    }
  }

  void _bannerForStage(String stage) {
    final order = _order;
    final r = order?.restaurantName ?? 'TastyLife';
    final d = order?.driverName ?? 'your driver';
    switch (stage) {
      case 'placed':
        _triggerNotification('Order Placed!', '$r is confirming your order.', Icons.receipt_long);
        break;
      case 'preparing':
        _triggerNotification('Preparing Order!', 'Chef is starting on your hot meal.', Icons.restaurant_menu);
        break;
      case 'outForDelivery':
        _triggerNotification('Rider on the Way!', '$d is bringing your food.', Icons.pedal_bike);
        break;
      case 'arrived':
        _triggerNotification('Driver Arrived!',
            '$d is outside with your order! PIN: ${order?.verificationPin ?? "8427"}', Icons.pin_drop);
        break;
    }
  }

  @override
  void dispose() {
    CartController.instance.removeListener(_onControllerChange);
    _callTimer?.cancel();
    _pulseTimer?.cancel();
    super.dispose();
  }

  // --- Notification Dispatch ---
  void _triggerNotification(String title, String message, IconData icon) {
    if (!mounted) return;
    setState(() {
      _notifTitle = title;
      _notifMsg = message;
      _notifIcon = icon;
      _showNotification = true;
    });
    HapticFeedback.heavyImpact();
    
    // Auto-dismiss after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showNotification = false;
        });
      }
    });
  }

  void _resetSimulation() {
    setState(() {
      _showNotification = false;
    });
    CartController.instance.resetSimulation();
    _triggerNotification(
      'Demo Reset!',
      'Starting the delivery simulation from the beginning.',
      Icons.refresh,
    );
  }

  // --- Voice Call Simulation ---
  void _startCall() {
    HapticFeedback.heavyImpact();
    setState(() {
      _activeCall = true;
      _callDuration = 0;
      _isMuted = false;
      _isSpeaker = false;
    });

    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _activeCall) {
        setState(() {
          _callDuration++;
        });
      }
    });

    _pulseTimer?.cancel();
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (mounted && _activeCall) {
        setState(() {
          _pulseVal = (_pulseVal + 0.015) % 1.0;
        });
      }
    });
  }

  void _endCall() {
    HapticFeedback.mediumImpact();
    _callTimer?.cancel();
    _pulseTimer?.cancel();
    setState(() {
      _activeCall = false;
    });
  }

  // --- Coordinate interpolation along the curved street path ---
  Alignment _interpolateDriverPosition() {
    if (_stage == DeliveryStage.placed || _stage == DeliveryStage.preparing) {
      // Driver waiting at the restaurant.
      return _routePoints.first;
    }
    if (_stage == DeliveryStage.arrived) {
      // Driver arrived at the customer home.
      return _routePoints.last;
    }

    // Out for delivery transit: Map transit phase (0.35 to 0.90) to path segments (0.0 to 1.0)
    final double transitFactor = ((_simProgress - 0.35) / 0.55).clamp(0.0, 1.0);
    final double totalSegments = (_routePoints.length - 1).toDouble();
    final double scaledProgress = transitFactor * totalSegments;
    final int index = scaledProgress.floor();
    final double segmentProgress = scaledProgress - index;

    return Alignment.lerp(_routePoints[index], _routePoints[index + 1], segmentProgress)!;
  }

  // --- ETA Minute calculation ---
  int get _minutesRemaining {
    final baseEta = _order?.etaMinute ?? 25;
    if (_stage == DeliveryStage.arrived) return 0;
    if (_simProgress >= 0.90) return 0;

    // Linear decrease from baseEta down to 2 mins as driver approaches home
    final double transitFactor = (_simProgress / 0.90).clamp(0.0, 1.0);
    return ((1.0 - transitFactor) * (baseEta - 2) + 2).round();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: CartController.instance,
      builder: (context, _) => Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ---------- Top bar ----------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'ORDER #${_order?.orderId ?? "TL-DEMO"}',
                              style: text.labelSmall?.copyWith(letterSpacing: 1.4),
                            ),
                            Text(
                              _stage == DeliveryStage.arrived ? 'Rider Arrived!' : 'Arriving Soon',
                              style: text.titleMedium?.copyWith(
                                color: _stage == DeliveryStage.arrived ? TastyColors.success : scheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _triggerNotification(
                            'Need Help?',
                            'TastyLife Customer Care hotline is active.',
                            Icons.contact_support,
                          );
                        },
                        icon: const Icon(Icons.help_outline),
                      ),
                    ],
                  ),
                ),
                
                // ---------- Map / Path Simulation Viewport ----------
                Expanded(
                  child: Stack(
                    children: [
                      // Grid & Street Vector Paint background
                      Positioned.fill(
                        child: CustomPaint(
                          painter: StreetGridPainter(
                            scheme: scheme,
                            progress: _simProgress,
                            stage: _stage,
                          ),
                        ),
                      ),
                      
                      // Pulse effect on Restaurant
                      _buildPulsingAura(_routePoints.first, scheme.primaryContainer, 40),

                      // Restaurant static marker pin
                      Align(
                        alignment: _routePoints.first,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            border: Border.all(color: scheme.primary, width: 2),
                            boxShadow: TastyShadows.ambient,
                          ),
                          child: Icon(Icons.restaurant, color: scheme.primary, size: 20),
                        ),
                      ),

                      // Pulse effect on Customer Home
                      _buildPulsingAura(_routePoints.last, Colors.orangeAccent, 40),

                      // Customer Home static marker pin
                      Align(
                        alignment: _routePoints.last,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.orangeAccent, width: 2),
                            boxShadow: TastyShadows.ambient,
                          ),
                          child: const Icon(Icons.home, color: Colors.orangeAccent, size: 22),
                        ),
                      ),

                      // Driver Approaching overlay pill badge
                      if (_stage == DeliveryStage.outForDelivery)
                        Positioned(
                          top: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: TastyRadii.fullRadius,
                                boxShadow: TastyShadows.glow,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.pedal_bike, color: scheme.onPrimaryContainer, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Driver is approaching',
                                    style: text.labelLarge?.copyWith(
                                      color: scheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Driver Bike animated pin with distance bubble
                      Align(
                        alignment: _interpolateDriverPosition(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: TastyShadows.glow,
                              ),
                              child: Icon(Icons.pedal_bike, color: scheme.onPrimary, size: 24),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerLowest,
                                borderRadius: TastyRadii.fullRadius,
                                boxShadow: TastyShadows.ambient,
                              ),
                              child: Text(
                                _stage == DeliveryStage.arrived
                                    ? 'Arrived'
                                    : '$_minutesRemaining min',
                                style: text.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // ---------- Status / Driver Card / Customer Action Container ----------
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(TastyRadii.xxl)),
                    boxShadow: TastyShadows.sheet,
                  ),
                  padding: const EdgeInsets.all(TastySpacing.gutterCard),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ETA Details
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _stage.label,
                                  style: text.labelMedium?.copyWith(
                                    color: _stage == DeliveryStage.arrived ? TastyColors.success : scheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                AnimatedSwitcher(
                                  duration: TastyMotion.durationMd,
                                  transitionBuilder: (child, anim) => SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.35),
                                      end: Offset.zero,
                                    ).animate(anim),
                                    child: FadeTransition(opacity: anim, child: child),
                                  ),
                                  child: Text(
                                    _stage == DeliveryStage.arrived
                                        ? 'Here Now!'
                                        : '$_minutesRemaining min',
                                    key: ValueKey(_minutesRemaining + _stage.index),
                                    style: text.displayLarge?.copyWith(
                                      fontSize: 40,
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _stage == DeliveryStage.arrived
                                  ? TastyColors.successContainer
                                  : TastyColors.successContainer,
                              borderRadius: TastyRadii.fullRadius,
                            ),
                            child: Text(
                              _stage == DeliveryStage.arrived ? 'Arrived' : 'On time',
                              style: text.labelMedium?.copyWith(
                                color: TastyColors.onSuccessContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Progress Bar
                      ClipRRect(
                        borderRadius: TastyRadii.fullRadius,
                        child: LinearProgressIndicator(
                          value: _stage == DeliveryStage.placed
                              ? 0.15
                              : _stage == DeliveryStage.preparing
                                  ? 0.4
                                  : _stage == DeliveryStage.outForDelivery
                                      ? 0.4 + 0.5 * ((_simProgress - 0.35) / 0.55)
                                      : 1.0,
                          minHeight: 6,
                          backgroundColor: scheme.surfaceContainer,
                          valueColor: AlwaysStoppedAnimation(scheme.primaryContainer),
                        ),
                      ),
                      const SizedBox(height: TastySpacing.stackLg),
                      
                      // Driver Info Card
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
                            ),
                          ),
                          const SizedBox(width: TastySpacing.stackMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_order?.driverName ?? 'Jean Kabila', style: text.titleSmall),
                                Row(
                                  children: [
                                    Icon(Icons.star_rounded, size: 14, color: scheme.primary),
                                    const SizedBox(width: 4),
                                    const Text('4.9 · Honda PCX', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _CircleButton(icon: Icons.call, onTap: _startCall),
                          const SizedBox(width: 8),
                          _CircleButton(
                            icon: Icons.chat_bubble,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ChatWithDriverScreen()),
                              );
                            },
                            filled: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: TastySpacing.stackMd),
                      const Divider(height: 1),
                      const SizedBox(height: TastySpacing.stackMd),
                      
                      // Order Totals Summary
                      Builder(builder: (_) {
                        final order = _order;
                        final restaurant = order?.restaurantName ?? 'TastyLife';
                        final itemCount = order?.itemCount ?? 0;
                        final total = order?.total ?? 17.50;
                        return Row(
                          children: [
                            Icon(Icons.restaurant_menu, color: scheme.primary),
                            const SizedBox(width: TastySpacing.stackMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(restaurant, style: text.titleSmall),
                                  Text(
                                    '$itemCount item${itemCount == 1 ? '' : 's'} · Paid',
                                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Text('\$${total.toStringAsFixed(2)}', style: text.titleSmall),
                          ],
                        );
                      }),
                      const SizedBox(height: TastySpacing.stackMd),

                      // Handoff Verification PIN Card
                      Container(
                        margin: const EdgeInsets.only(bottom: TastySpacing.stackMd),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: TastyRadii.xlRadius,
                          border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: scheme.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.key, color: scheme.primary, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Handoff Code', style: text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                    Text('Show this PIN to the rider', style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: TastyRadii.lgRadius,
                                boxShadow: TastyShadows.glow,
                              ),
                              child: Text(
                                _order?.verificationPin ?? '8427',
                                style: text.titleMedium?.copyWith(
                                  color: scheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Complete Delivery Button (Enabled only when driver has arrived)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _stage == DeliveryStage.arrived
                              ? () {
                                  HapticFeedback.mediumImpact();
                                  // Order received → move it out of live
                                  // tracking and into order history.
                                  CartController.instance.markActiveOrderReceived();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (_) => const RateExperienceScreen()),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            _stage == DeliveryStage.arrived
                                ? "I've received my order"
                                : "Waiting for delivery...",
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _stage == DeliveryStage.arrived
                                ? scheme.primaryContainer
                                : scheme.surfaceContainerLow,
                            foregroundColor: _stage == DeliveryStage.arrived
                                ? scheme.onPrimaryContainer
                                : scheme.onSurfaceVariant,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ---------- Slide-down Notification Banner Overlay ----------
            _buildNotificationBanner(scheme, text),

            // ---------- Floating Developer Control Deck Overlay ----------
            // Hidden in release/profile builds so clients never see the
            // 1x/10x/50x speed knob or the stage-jump buttons.
            if (kDebugMode) _buildDevPanel(scheme, text),

            // ---------- Fullscreen Voice Call Simulation Overlay ----------
            if (_activeCall) _buildCallOverlay(),
          ],
        ),
      ),
    ),
    );
  }

  // --- Notification Banner Constructor ---
  Widget _buildNotificationBanner(ColorScheme scheme, TextTheme text) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: AnimatedSlide(
        offset: _showNotification ? Offset.zero : const Offset(0, -1.8),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: _showNotification ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: TastyRadii.xlRadius,
              border: Border.all(color: scheme.primary.withValues(alpha: 0.35), width: 1.5),
              boxShadow: TastyShadows.glow,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_notifIcon, color: scheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _notifTitle,
                        style: text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _notifMsg,
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 16, color: scheme.onSurfaceVariant),
                  onPressed: () => setState(() => _showNotification = false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Developer Control Deck Constructors ---
  Widget _buildDevPanel(ColorScheme scheme, TextTheme text) {
    return Positioned(
      top: 68,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _devPanelOpen = !_devPanelOpen);
            },
            backgroundColor: _devPanelOpen ? scheme.primary : scheme.surfaceContainerLowest,
            foregroundColor: _devPanelOpen ? scheme.onPrimary : scheme.primary,
            child: const Icon(Icons.tune),
          ),
          if (_devPanelOpen) ...[
            const SizedBox(height: 8),
            Container(
              width: 240,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest.withValues(alpha: 0.95),
                borderRadius: TastyRadii.xlRadius,
                border: Border.all(color: scheme.outlineVariant),
                boxShadow: TastyShadows.ambient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings, size: 16, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Demo Control Deck',
                        style: text.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Text(
                    'SIMULATION SPEED',
                    style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSpeedBtn('1x', 1.0),
                      _buildSpeedBtn('10x', 10.0),
                      _buildSpeedBtn('50x', 50.0),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'STAGE JUMP',
                    style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildStageJumpBtn('Placed', 0.05),
                      _buildStageJumpBtn('Prepped', 0.25),
                      _buildStageJumpBtn('Transit', 0.60),
                      _buildStageJumpBtn('Arrived', 0.95),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _resetSimulation,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Reset'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          CartController.instance.toggleSimPlaying();
                        },
                        icon: Icon(
                          CartController.instance.simPlaying ? Icons.pause : Icons.play_arrow,
                          size: 16,
                        ),
                        label: Text(CartController.instance.simPlaying ? 'Pause' : 'Play'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSpeedBtn(String label, double val) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final active = CartController.instance.simSpeed == val;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        CartController.instance.setSimSpeed(val);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? scheme.primaryContainer : scheme.surfaceContainerLow,
          borderRadius: TastyRadii.mdRadius,
        ),
        child: Text(
          label,
          style: text.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: active ? scheme.onPrimaryContainer : scheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildStageJumpBtn(String label, double progressVal) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        CartController.instance.jumpSimToProgress(progressVal);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: TastyRadii.mdRadius,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          label,
          style: text.labelSmall?.copyWith(fontSize: 10),
        ),
      ),
    );
  }

  // --- Voice Call Screen Overlay Constructor ---
  Widget _buildCallOverlay() {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final dName = _order?.driverName ?? 'Jean Kabila';
    final durationStr = '${(_callDuration ~/ 60).toString()}:${(_callDuration % 60).toString().padLeft(2, '0')}';

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.93),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  'TASTYLIFE VOICE CALL',
                  style: text.labelSmall?.copyWith(color: Colors.white60, letterSpacing: 1.8),
                ),
                const SizedBox(height: 16),
                Text(
                  dName,
                  style: text.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  _callDuration > 0 ? durationStr : 'Connecting...',
                  style: text.bodyLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            
            // Avatar with pulse rings
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildCallPulseRing(3.0),
                  _buildCallPulseRing(2.0),
                  _buildCallPulseRing(1.0),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Call Controls
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCallAction(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      label: 'Mute',
                      active: _isMuted,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _isMuted = !_isMuted);
                      },
                    ),
                    _buildCallAction(
                      icon: Icons.dialpad,
                      label: 'Keypad',
                      active: false,
                      onTap: HapticFeedback.lightImpact,
                    ),
                    _buildCallAction(
                      icon: _isSpeaker ? Icons.volume_up : Icons.volume_down,
                      label: 'Speaker',
                      active: _isSpeaker,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _isSpeaker = !_isSpeaker);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                FloatingActionButton(
                  onPressed: _endCall,
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.call_end, size: 28),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallPulseRing(double factor) {
    final double value = (_pulseVal + factor / 3.0) % 1.0;
    return Opacity(
      opacity: (1.0 - value).clamp(0.0, 1.0) * 0.45,
      child: Container(
        width: 140 + (value * 120),
        height: 140 + (value * 120),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: TastyColors.brandOrange, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildCallAction({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? scheme.primary : Colors.white12,
            ),
            child: Icon(icon, color: active ? scheme.onPrimary : Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  // --- Pulsing Aura for Pins ---
  Widget _buildPulsingAura(Alignment align, Color color, double radius) {
    return Align(
      alignment: align,
      child: Container(
        width: radius * 2.2,
        height: radius * 2.2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

// --- Circle Button for driver options ---
class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap, this.filled = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = filled ? scheme.primaryContainer : scheme.surfaceContainerHigh;
    final fg = filled ? scheme.onPrimaryContainer : scheme.onSurface;
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: fg, size: 20),
        ),
      ),
    );
  }
}

// --- Custom Street Map & Dotted Routing Path Painter ---
class StreetGridPainter extends CustomPainter {
  StreetGridPainter({required this.scheme, required this.progress, required this.stage});
  final ColorScheme scheme;
  final double progress;
  final DeliveryStage stage;

  Offset _getOffset(Alignment alignment, Size size) {
    return Offset(
      size.width / 2 + (size.width / 2) * alignment.x,
      size.height / 2 + (size.height / 2) * alignment.y,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Warm vector ambient background
    final bgPaint = Paint()..color = scheme.surfaceContainerLow;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Dotted technical map grid
    final gridPaint = Paint()
      ..color = scheme.outlineVariant.withValues(alpha: 0.18)
      ..strokeWidth = 1.0;

    const double gridSize = 32.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. Visual Street Paths (Kinshasa Gombe layout inspired lines)
    final streetPaint = Paint()
      ..color = scheme.onSurface.withValues(alpha: 0.08)
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round;

    final streets = [
      [const Offset(50, 40), Offset(size.width - 50, 40)],
      [Offset(30, size.height / 2), Offset(size.width - 30, size.height / 2)],
      [Offset(60, size.height - 40), Offset(size.width - 60, size.height - 40)],
      [const Offset(80, 20), Offset(80, size.height - 20)],
      [Offset(size.width - 80, 20), Offset(size.width - 80, size.height - 20)],
      [Offset(size.width / 2, 40), Offset(size.width / 2, size.height - 40)],
    ];

    for (final s in streets) {
      canvas.drawLine(s[0], s[1], streetPaint);
    }

    // 4. Highlighted Curved Dotted Delivery Route Path
    final routePaint = Paint()
      ..color = scheme.primary.withValues(alpha: 0.75)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    final List<Alignment> points = const [
      Alignment(0.0, -0.55),
      Alignment(-0.45, -0.3),
      Alignment(0.35, -0.05),
      Alignment(-0.25, 0.25),
      Alignment(0.0, 0.55),
    ];

    final startOffset = _getOffset(points[0], size);
    path.moveTo(startOffset.dx, startOffset.dy);
    for (int i = 1; i < points.length; i++) {
      final pOffset = _getOffset(points[i], size);
      path.lineTo(pOffset.dx, pOffset.dy);
    }

    // Dynamic glowing overlay under dotted path
    final tracePaint = Paint()
      ..color = scheme.primary.withValues(alpha: 0.15)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, tracePaint);

    // Compute dashed line spacing manually for 100% compatibility across platforms
    final double dashWidth = 6.0;
    final double dashSpace = 4.0;
    final Path dashedPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, (distance + dashWidth).clamp(0.0, metric.length)),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, routePaint);
  }

  @override
  bool shouldRepaint(covariant StreetGridPainter old) {
    return old.progress != progress || old.stage != stage;
  }
}
