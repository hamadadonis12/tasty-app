import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

/// 1 USD ≈ 2 700 CDF (Congolese Franc). Used for the dual-currency display
/// required by PRD FR-C-007. A real implementation would fetch this daily
/// from the backend; for the demo it stays fixed.
const double kUsdToCdf = 2700.0;

/// A single event in the customer's notifications feed — order placed,
/// preparing, picked up, arrived, marketing nudge, etc. Persisted to
/// [CartController.notifications] so the Notifications screen renders a
/// live log instead of overwriting the same row.
@immutable
class NotificationEvent {
  const NotificationEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.timestamp,
    this.isOrderEvent = false,
  });

  final String id;
  final String title;
  final String subtitle;
  /// Stored as code-point + font family so the data class stays pure-Dart.
  final int iconCodePoint;
  final String? iconFontFamily;
  final DateTime timestamp;
  /// True for in-progress order updates so the notifications screen can
  /// pin them to TODAY even before the date math runs.
  final bool isOrderEvent;
}

/// Format a USD amount as CDF, no decimals, thin-spaces between thousands.
String formatCdf(double usd) {
  final n = (usd * kUsdToCdf).round();
  final str = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
    buf.write(str[i]);
  }
  return '${buf.toString()} FC';
}

/// Snapshot of the cart at the moment "Confirm Order" is tapped. Used by
/// the success + tracking screens so they show the user's real order
/// instead of hard-coded mockups.
@immutable
class ActiveOrder {
  const ActiveOrder({
    required this.orderId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.paymentLabel,
    required this.driverName,
    required this.driverInitials,
    required this.etaMinute,
    required this.verificationPin,
    this.discount = 0.0,
    this.tip = 0.0,
    this.contactless = false,
  });

  final String orderId;
  final String restaurantName;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final String paymentLabel;
  final String driverName;
  final String driverInitials;
  /// Used to seed the live-tracking ETA ticker (`19:${etaMinute}` style).
  final int etaMinute;
  final String verificationPin;
  final double discount;
  /// Optional driver tip the customer added at checkout.
  final double tip;
  /// True when the customer chose "leave at door" contactless delivery.
  final bool contactless;

  double get total =>
      (subtotal + deliveryFee + serviceFee + tip - discount).clamp(0.0, double.infinity);
  int get itemCount => items.fold(0, (s, it) => s + it.quantity);
}

/// Snapshot of a past order for display in the order history.
@immutable
class OrderHistoryItem {
  const OrderHistoryItem({
    required this.orderId,
    required this.restaurantName,
    required this.date,
    required this.itemsDescription,
    required this.total,
    required this.image,
    required this.items,
    required this.verificationPin,
    this.driverName = '',
    this.driverInitials = '',
    this.driverVehicle = '',
    this.deliveryAddress = '',
    this.paymentLabel = 'Orange Money',
    this.deliveryFee = 0,
    this.serviceFee = 0,
  });

  final String orderId;
  final String restaurantName;
  final String date;
  final String itemsDescription;
  final double total;
  final String image;
  final List<CartItem> items;
  final String verificationPin;

  /// How it reached you — driver + delivery details shown on Order Details.
  final String driverName;
  final String driverInitials;
  final String driverVehicle;
  final String deliveryAddress;
  final String paymentLabel;
  final double deliveryFee;
  final double serviceFee;

  /// Derived so the receipt/details breakdown always reconciles to [total].
  double get subtotal =>
      (total - deliveryFee - serviceFee).clamp(0.0, double.infinity);
}


/// A single line in the cart.
@immutable
class CartItem {
  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.modifier,
    this.quantity = 1,
  });

  final String id;
  final String name;
  final double price;
  final String image;
  final String? modifier;
  final int quantity;

  double get lineTotal => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        name: name,
        price: price,
        image: image,
        modifier: modifier,
        quantity: quantity ?? this.quantity,
      );
}

/// Process-wide cart state. Plain [ChangeNotifier] singleton so screens
/// can rebuild via [AnimatedBuilder] / [ListenableBuilder] without
/// dragging in a state-management dependency.
///
/// ```dart
/// CartController.instance.add(CartItem(...));
/// ListenableBuilder(
///   listenable: CartController.instance,
///   builder: (_, __) => Text('${CartController.instance.itemCount}'),
/// );
/// ```
class CartController extends ChangeNotifier {
  CartController._() {
    _initPastOrders();
    _seedNotifications();
  }
  static final CartController instance = CartController._();

  // ─── Notifications feed ─────────────────────────────────────────────
  final List<NotificationEvent> _notifications = <NotificationEvent>[];
  List<NotificationEvent> get notifications => List.unmodifiable(_notifications);

  void _seedNotifications() {
    // Static marketing / system events seeded once. Order-stage events
    // are pushed live by [pushOrderEvent] as stages advance.
    final now = DateTime.now();
    _notifications.addAll([
      NotificationEvent(
        id: 'gold-member',
        title: "You're now a Gold member",
        subtitle: '50 orders unlocked free delivery for a month',
        iconCodePoint: Icons.star_rounded.codePoint,
        iconFontFamily: Icons.star_rounded.fontFamily,
        timestamp: now.subtract(const Duration(days: 2)),
      ),
      NotificationEvent(
        id: 'wallet-topup',
        title: 'Wallet top-up of 25 000 FC',
        subtitle: 'Orange Money · receipt sent',
        iconCodePoint: Icons.payments.codePoint,
        iconFontFamily: Icons.payments.fontFamily,
        timestamp: now.subtract(const Duration(days: 3)),
      ),
      NotificationEvent(
        id: 'sushi-lounge',
        title: 'New on TastyLife: Sushi Lounge',
        subtitle: 'Limete · opens daily 11am–10pm',
        iconCodePoint: Icons.restaurant.codePoint,
        iconFontFamily: Icons.restaurant.fontFamily,
        timestamp: now.subtract(const Duration(days: 8)),
      ),
      NotificationEvent(
        id: 'app-update',
        title: 'New app update available',
        subtitle: 'Tap to install v2.4.0',
        iconCodePoint: Icons.system_update_alt.codePoint,
        iconFontFamily: Icons.system_update_alt.fontFamily,
        timestamp: now.subtract(const Duration(days: 14)),
      ),
    ]);
  }

  /// Push a live order-stage event into the notifications feed. Called by
  /// [LiveOrderTrackingScreen] on each stage transition so the customer
  /// sees a running log instead of one row that mutates.
  void pushOrderEvent({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    _notifications.insert(0, NotificationEvent(
      id: 'order-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily,
      timestamp: DateTime.now(),
      isOrderEvent: true,
    ));
    notifyListeners();
  }

  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  final List<OrderHistoryItem> _pastOrders = [];
  List<OrderHistoryItem> get pastOrders => List.unmodifiable(_pastOrders);

  void _initPastOrders() {
    _pastOrders.addAll([
      const OrderHistoryItem(
        orderId: 'TL-8941',
        restaurantName: 'Le Relais de la Cité',
        date: 'Oct 24, 2024 · 19:30',
        itemsDescription: '2× Poulet Mayo Grillé, 1× Frites Maison, 2× Coca-Cola',
        total: 34.50,
        image: 'https://images.unsplash.com/photo-1604908177453-7462950a6a3b?w=200&q=80',
        items: [],
        verificationPin: '8427',
        driverName: 'Patrick Mbuyi',
        driverInitials: 'PM',
        driverVehicle: 'Motorbike · 9821 AB/05',
        deliveryAddress: '14 Avenue du Commerce, Gombe',
        paymentLabel: 'Orange Money',
        deliveryFee: 2.00,
        serviceFee: 1.50,
      ),
      const OrderHistoryItem(
        orderId: 'TL-5731',
        restaurantName: 'Pizzeria Napoli Gombe',
        date: 'Oct 18, 2024 · 20:15',
        itemsDescription: '1× Margherita Grande, 1× Tiramisu',
        total: 22.00,
        image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200&q=80',
        items: [],
        verificationPin: '5521',
        driverName: 'Christian Tshibanda',
        driverInitials: 'CT',
        driverVehicle: 'Motorbike · 4417 CD/05',
        deliveryAddress: '22 Avenue Kasa-Vubu, Kasa-Vubu',
        paymentLabel: 'Airtel Money',
        deliveryFee: 2.50,
        serviceFee: 1.00,
      ),
      const OrderHistoryItem(
        orderId: 'TL-3420',
        restaurantName: 'Sushi Lounge',
        date: 'Oct 12, 2024 · 21:00',
        itemsDescription: '1× Dragon Roll, 1× Salmon Nigiri, 1× Edamame',
        total: 28.50,
        image: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=200&q=80',
        items: [],
        verificationPin: '1945',
        driverName: 'Merveille Ilunga',
        driverInitials: 'MI',
        driverVehicle: 'Motorbike · 6390 EF/05',
        deliveryAddress: '8 Boulevard du 30 Juin, Gombe',
        paymentLabel: 'Orange Money',
        deliveryFee: 3.50,
        serviceFee: 1.50,
      ),
    ]);
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthStr = months[now.month - 1];
    final minuteStr = now.minute.toString().padLeft(2, '0');
    return '$monthStr ${now.day}, ${now.year} · ${now.hour}:$minuteStr';
  }


  /// The restaurant the current cart belongs to. Set on the first add and
  /// cleared on checkout / clear.
  String? _restaurantId;
  String? _restaurantName;
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;

  /// The order that was just placed, exposed to the success and tracking
  /// screens so they can show the customer's real items + total.
  ActiveOrder? _activeOrder;
  ActiveOrder? get activeOrder => _activeOrder;

  /// History snapshot of the active order, held aside while the order is
  /// still in progress. It only gets committed to [pastOrders] once the
  /// customer confirms receipt via [markActiveOrderReceived], so an in-flight
  /// order shows as "active" — not in history — until it's actually received.
  OrderHistoryItem? _activeOrderHistory;

  double _discount = 0.0;
  double get discount => _discount;

  void applyDiscount(double amount) {
    _discount = amount;
    notifyListeners();
  }

  /// In-memory set of restaurant IDs the user has favourited this session.
  final Set<String> _favoriteRestaurantIds = <String>{};
  bool isFavorite(String restaurantId) => _favoriteRestaurantIds.contains(restaurantId);
  int get favoriteCount => _favoriteRestaurantIds.length;
  void toggleFavorite(String restaurantId) {
    if (!_favoriteRestaurantIds.add(restaurantId)) {
      _favoriteRestaurantIds.remove(restaurantId);
    }
    notifyListeners();
  }

  /// Recent search queries, newest-first, capped at 6.
  final List<String> _recentSearches = <String>[];
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  void pushRecentSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    _recentSearches.remove(q);
    _recentSearches.insert(0, q);
    while (_recentSearches.length > 6) {
      _recentSearches.removeLast();
    }
    notifyListeners();
  }

  /// Dietary filters active in Smart Search (vegetarian, halal, etc).
  final Set<String> _dietaryFilters = <String>{};
  Set<String> get dietaryFilters => Set.unmodifiable(_dietaryFilters);
  void toggleDietary(String tag) {
    if (!_dietaryFilters.add(tag)) {
      _dietaryFilters.remove(tag);
    }
    notifyListeners();
  }

  // ─── Loyalty / Tasty Stars ────────────────────────────────────────────
  /// Current loyalty balance. Starts at 12 450 to match the demo screens.
  int _loyaltyPoints = 12450;
  int get loyaltyPoints => _loyaltyPoints;

  /// Threshold of the next tier (Platinum). Used to render the tier
  /// progress bar on the loyalty screen and the home/account widgets.
  static const int loyaltyTierTarget = 15000;
  int get pointsToNextTier => (loyaltyTierTarget - _loyaltyPoints).clamp(0, loyaltyTierTarget);

  /// IDs of rewards the user has already redeemed this session. Used to
  /// switch the per-row CTA from "Redeem" to "Redeemed".
  final Set<String> _redeemedRewardIds = <String>{};
  bool isRewardRedeemed(String id) => _redeemedRewardIds.contains(id);

  /// Spends [cost] points on a reward and adds [creditUsd] to the cart
  /// discount so the next checkout is cheaper. Returns false if the user
  /// can't afford the reward, true on success.
  bool redeemReward({
    required String id,
    required int cost,
    required double creditUsd,
  }) {
    if (_loyaltyPoints < cost || _redeemedRewardIds.contains(id)) return false;
    _loyaltyPoints -= cost;
    _redeemedRewardIds.add(id);
    _discount += creditUsd;
    notifyListeners();
    return true;
  }

  /// Awarded automatically when an order is placed: 1 point per USD spent.
  /// Called from [placeOrder] below.
  void _earnLoyaltyFromOrder(double total) {
    final earned = total.floor();
    if (earned <= 0) return;
    _loyaltyPoints += earned;
  }

  // ─── Order tracking simulation ──────────────────────────────────────
  // Lives in the controller (not the screen) so the simulation continues
  // when the customer backs out of the tracking screen and resumes
  // wherever they left off.
  Timer? _simTimer;
  double _simProgress = 0.0;
  String _simStage = 'placed';
  double _simSpeed = 1.0;
  bool _simPlaying = true;

  double get simProgress => _simProgress;
  String get simStage => _simStage;
  double get simSpeed => _simSpeed;
  bool get simPlaying => _simPlaying;

  /// Old API kept so the tracking screen's `updateSimulation` calls
  /// (which were previously the only writer) still compile. New code
  /// should use [startOrderSimulation] / [setSimSpeed] etc.
  void updateSimulation(double progress, String stage) {
    _simProgress = progress;
    _simStage = stage;
    notifyListeners();
  }

  void _startOrderSimulation() {
    _simTimer?.cancel();
    _simProgress = 0.0;
    _simStage = 'placed';
    _simPlaying = true;
    _simTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_simPlaying) return;
      final step = 0.00167 * _simSpeed;
      _simProgress = (_simProgress + step).clamp(0.0, 1.0);
      _advanceStageIfNeeded();
      if (_simProgress >= 1.0) {
        _simPlaying = false;
        _simTimer?.cancel();
      }
      notifyListeners();
    });
  }

  void _advanceStageIfNeeded() {
    final prev = _simStage;
    String next;
    if (_simProgress < 0.15) {
      next = 'placed';
    } else if (_simProgress < 0.35) {
      next = 'preparing';
    } else if (_simProgress < 0.90) {
      next = 'outForDelivery';
    } else {
      next = 'arrived';
    }
    if (next != prev) {
      _simStage = next;
      _pushStageNotification(next);
    }
  }

  void _pushStageNotification(String stage) {
    final order = _activeOrder;
    final rName = order?.restaurantName ?? 'TastyLife';
    final dName = order?.driverName ?? 'your driver';
    switch (stage) {
      case 'preparing':
        pushOrderEvent(
          title: 'Preparing Order!',
          subtitle: 'Chef at $rName is starting on your meal.',
          icon: Icons.restaurant_menu,
        );
        break;
      case 'outForDelivery':
        pushOrderEvent(
          title: 'Rider on the Way!',
          subtitle: '$dName picked up your order.',
          icon: Icons.pedal_bike,
        );
        break;
      case 'arrived':
        pushOrderEvent(
          title: 'Driver Arrived!',
          subtitle: '$dName is outside. PIN: ${order?.verificationPin ?? "8427"}',
          icon: Icons.pin_drop,
        );
        break;
    }
  }

  void setSimSpeed(double speed) {
    _simSpeed = speed;
    _simPlaying = true;
    notifyListeners();
  }

  void toggleSimPlaying() {
    _simPlaying = !_simPlaying;
    notifyListeners();
  }

  void jumpSimToProgress(double progress) {
    _simProgress = progress.clamp(0.0, 1.0);
    _advanceStageIfNeeded();
    notifyListeners();
  }

  void resetSimulation() {
    _simTimer?.cancel();
    _simProgress = 0.0;
    _simStage = 'placed';
    _simSpeed = 1.0;
    _simPlaying = true;
    notifyListeners();
    _startOrderSimulation();
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }

  /// Attach the cart to a restaurant. If a different restaurant already
  /// owns the cart, returns false (the UI should warn before clearing).
  bool setRestaurant({required String id, required String name}) {
    if (_restaurantId != null && _restaurantId != id && _items.isNotEmpty) {
      return false;
    }
    _restaurantId = id;
    _restaurantName = name;
    return true;
  }

  /// Total number of units across all items (not the number of distinct lines).
  int get itemCount => _items.fold(0, (sum, it) => sum + it.quantity);

  /// Pre-fees subtotal.
  double get subtotal => _items.fold(0, (sum, it) => sum + it.lineTotal);

  /// Add an item to the cart, merging quantities if an identical line
  /// (same id + modifier) is already present.
  void add(CartItem item) {
    final i = _items.indexWhere(
      (e) => e.id == item.id && e.modifier == item.modifier,
    );
    if (i == -1) {
      _items.add(item);
    } else {
      _items[i] = _items[i].copyWith(quantity: _items[i].quantity + item.quantity);
    }
    notifyListeners();
  }

  void inc(int index) {
    if (index < 0 || index >= _items.length) return;
    _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
    notifyListeners();
  }

  void dec(int index) {
    if (index < 0 || index >= _items.length) return;
    final next = _items[index].quantity - 1;
    if (next <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: next);
    }
    notifyListeners();
  }

  void remove(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty && _restaurantId == null) return;
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    notifyListeners();
  }

  /// Drivers cycled through on placeOrder so successive demo orders don't
  /// all look like they were taken by the same person. First/last name
  /// indices rotate independently for variety.
  static const _driverFirstNames = ['Jean', 'Patrick', 'Bosco', 'Christian', 'Merveille', 'Rachel'];
  static const _driverLastNames = ['Kabila', 'Mbuyi', 'Tshibanda', 'Lumumba', 'Mukendi', 'Ilunga'];

  /// Snapshot the cart into an [ActiveOrder] and clear the cart. The
  /// active order is exposed via [activeOrder] so downstream screens (order
  /// success, live tracking) can read the real values instead of hard-coded
  /// placeholders.
  ActiveOrder placeOrder({
    required double deliveryFee,
    required double serviceFee,
    required String paymentLabel,
    double tip = 0.0,
    bool contactless = false,
  }) {
    final now = DateTime.now();
    final verificationPin = (1000 + now.millisecondsSinceEpoch % 9000).toString();
    final firstName = _driverFirstNames[now.millisecondsSinceEpoch % _driverFirstNames.length];
    final lastName = _driverLastNames[(now.millisecondsSinceEpoch ~/ 7) % _driverLastNames.length];
    final driverName = '$firstName $lastName';
    final driverInitials = '${firstName[0]}${lastName[0]}';
    final order = ActiveOrder(
      orderId: 'TL-${now.millisecondsSinceEpoch % 10000}',
      restaurantName: _restaurantName ?? 'TastyLife',
      items: List.unmodifiable(_items),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
      paymentLabel: paymentLabel,
      driverName: driverName,
      driverInitials: driverInitials,
      etaMinute: 22 + now.second % 18,
      verificationPin: verificationPin,
      discount: _discount,
      tip: tip,
      contactless: contactless,
    );
    _activeOrder = order;
    _earnLoyaltyFromOrder(order.total);
    pushOrderEvent(
      title: 'Order Placed!',
      subtitle: '${order.restaurantName} is confirming your order.',
      icon: Icons.receipt_long,
    );
    _startOrderSimulation();

    // Snapshot a history record but hold it aside as *pending*. It is only
    // committed to [pastOrders] when the customer confirms receipt (see
    // [markActiveOrderReceived]) — until then the order lives in live tracking.
    _activeOrderHistory = OrderHistoryItem(
      orderId: order.orderId,
      restaurantName: order.restaurantName,
      date: _formatCurrentDate(),
      itemsDescription: _items.map((it) => '${it.quantity}× ${it.name}').join(', '),
      total: order.total,
      image: _items.isNotEmpty
          ? _items.first.image
          : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200&q=80',
      items: List.unmodifiable(_items),
      verificationPin: verificationPin,
      driverName: order.driverName,
      driverInitials: order.driverInitials,
      driverVehicle: 'Motorbike',
      deliveryAddress: '14 Avenue du Commerce, Gombe',
      paymentLabel: order.paymentLabel,
      deliveryFee: order.deliveryFee,
      serviceFee: order.serviceFee,
    );

    // Persist placed order to the database API service
    ApiService.instance.saveOrderToDatabase(order);

    _items.clear();
    _discount = 0.0; // Clear dynamic discount after order success
    _restaurantId = null;
    _restaurantName = null;
    _simProgress = 0.0;
    _simStage = 'placed';
    notifyListeners();
    return order;
  }

  /// Confirm the customer has received the active order. This is the moment
  /// the order graduates from *live tracking* to *order history*: the pending
  /// history snapshot is committed to [pastOrders], the active order and its
  /// tracking simulation are cleared, so the "active order" UI (the home
  /// track-bar and the in-progress card on the orders screen) disappears and
  /// the order now appears in the past-orders list.
  ///
  /// Safe to call when there is no active order — it simply no-ops.
  void markActiveOrderReceived() {
    if (_activeOrder == null && _activeOrderHistory == null) return;
    final history = _activeOrderHistory;
    if (history != null) {
      _pastOrders.insert(0, history);
    }
    _activeOrderHistory = null;
    _activeOrder = null;
    _simTimer?.cancel();
    _simProgress = 0.0;
    _simStage = 'placed';
    _simPlaying = false;
    notifyListeners();
  }

  /// Seed the cart with a couple of items so the demo has something to
  /// show on first open. Only seeds if currently empty.
  void seedIfEmpty() {
    if (_items.isNotEmpty) return;
    _items.addAll(const [
      CartItem(
        id: 'poulet-mayo-wrap',
        name: 'Poulet Mayo Wrap',
        price: 8.50,
        image: 'https://images.unsplash.com/photo-1604908177453-7462950a6a3b?w=200&q=80',
      ),
      CartItem(
        id: 'mango-juice',
        name: 'Fresh Mango Juice',
        price: 3.00,
        image: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=200&q=80',
        quantity: 2,
      ),
    ]);
    notifyListeners();
  }
}
