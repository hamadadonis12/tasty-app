import 'package:flutter/foundation.dart';

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

  double get total => subtotal + deliveryFee + serviceFee;
  int get itemCount => items.fold(0, (s, it) => s + it.quantity);
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
  CartController._();
  static final CartController instance = CartController._();

  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

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

  /// Snapshot the cart into an [ActiveOrder] and clear the cart. The
  /// active order is exposed via [activeOrder] so downstream screens (order
  /// success, live tracking) can read the real values instead of hard-coded
  /// placeholders.
  ActiveOrder placeOrder({
    required double deliveryFee,
    required double serviceFee,
    required String paymentLabel,
  }) {
    final order = ActiveOrder(
      orderId: 'TL-${DateTime.now().millisecondsSinceEpoch % 10000}',
      restaurantName: _restaurantName ?? 'TastyLife',
      items: List.unmodifiable(_items),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
      paymentLabel: paymentLabel,
      driverName: 'Jean Kabila',
      driverInitials: 'JK',
      etaMinute: 22 + DateTime.now().second % 18,
    );
    _activeOrder = order;
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    notifyListeners();
    return order;
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
