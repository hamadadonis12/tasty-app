import 'package:flutter/material.dart';

/// 1 USD ≈ 2 700 CDF — mirrors [kUsdToCdf] in cart_controller. Kept local so
/// the wallet can format Franc amounts without importing the cart.
const double _usdToCdf = 2700.0;

/// Format an integer Franc amount with thin-space thousands separators, e.g.
/// `45800` → `45 800 FC`. [signed] prefixes a `+` for positive values.
String formatFc(int fc, {bool signed = false}) {
  final neg = fc < 0;
  final digits = fc.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  final sign = neg ? '−' : (signed ? '+' : '');
  return '$sign${buf.toString()} FC';
}

/// The three launch languages for the Kinshasa / Brazzaville market.
enum AppLanguage { francais, english, lingala }

extension AppLanguageX on AppLanguage {
  String get label => switch (this) {
        AppLanguage.francais => 'Français',
        AppLanguage.english => 'English',
        AppLanguage.lingala => 'Lingála',
      };

  String get nativeSubtitle => switch (this) {
        AppLanguage.francais => 'French',
        AppLanguage.english => 'English',
        AppLanguage.lingala => 'Lingala',
      };

  String get flag => switch (this) {
        AppLanguage.francais => '🇫🇷',
        AppLanguage.english => '🇬🇧',
        AppLanguage.lingala => '🇨🇩',
      };
}

/// A saved payment method (mobile money, card, or cash).
class PaymentMethod {
  const PaymentMethod({required this.icon, required this.label, required this.sub});
  final IconData icon;
  final String label;
  final String sub;
}

/// A single wallet ledger entry. [amountFc] is signed: negative for spend,
/// positive for top-ups / refunds / bonuses.
class WalletTx {
  const WalletTx({
    required this.label,
    required this.amountFc,
    required this.sub,
    required this.icon,
  });
  final String label;
  final int amountFc;
  final String sub;
  final IconData icon;

  bool get positive => amountFc >= 0;
}

/// Process-wide profile + preferences + wallet state. Plain [ChangeNotifier]
/// singleton, matching the pattern used by `CartController`, so screens can
/// rebuild via [ListenableBuilder] without a state-management dependency.
///
/// This is what makes the formerly "coming soon" account & wallet actions
/// (edit profile, language, theme, send credit, add method, top up) real:
/// they mutate this shared state and every listening screen updates.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  // ─── Profile ────────────────────────────────────────────────────────
  String _name = 'Merveille Kabanga';
  String _email = 'merveille.k@example.cd';
  String _phone = '+243 89 123 4567';
  String _memberTier = 'Gold Member';

  /// Network avatar used until the customer picks their own photo.
  String _avatarUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80';

  /// Local file path of a photo the customer picked (Batch B / image_picker).
  /// When set, it takes precedence over [avatarUrl].
  String? _avatarFilePath;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get memberTier => _memberTier;
  String get avatarUrl => _avatarUrl;
  String? get avatarFilePath => _avatarFilePath;

  /// First name only, for greetings.
  String get firstName => _name.split(' ').first;

  void updateProfile({String? name, String? email, String? phone}) {
    if (name != null && name.trim().isNotEmpty) _name = name.trim();
    if (email != null) _email = email.trim();
    if (phone != null) _phone = phone.trim();
    notifyListeners();
  }

  void setAvatarFile(String path) {
    _avatarFilePath = path;
    notifyListeners();
  }

  /// Pick one of the curated avatars (clears any local photo).
  void setAvatarUrl(String url) {
    _avatarUrl = url;
    _avatarFilePath = null;
    notifyListeners();
  }

  /// Curated avatar choices offered in the photo picker.
  static const List<String> avatarChoices = [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
    'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=200&q=80',
  ];

  // ─── Delivery location (shown in the app header) ─────────────────────
  // Drives the Toters-style location selector in the home header. Defaults
  // to a Gombe (Kinshasa) address; updated when the customer picks another.
  String _addressLabel = 'Home';
  String _addressLine = '12 Avenue du Commerce, Gombe, Kinshasa';

  String get addressLabel => _addressLabel;
  String get addressLine => _addressLine;

  void setAddress({String? label, String? line}) {
    if (label != null && label.trim().isNotEmpty) _addressLabel = label.trim();
    if (line != null && line.trim().isNotEmpty) _addressLine = line.trim();
    notifyListeners();
  }

  // ─── Preferences ────────────────────────────────────────────────────
  AppLanguage _language = AppLanguage.francais;
  ThemeMode _themeMode = ThemeMode.system;

  AppLanguage get language => _language;
  ThemeMode get themeMode => _themeMode;

  String get themeModeLabel => switch (_themeMode) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  void setLanguage(AppLanguage l) {
    _language = l;
    notifyListeners();
  }

  void setThemeMode(ThemeMode m) {
    _themeMode = m;
    notifyListeners();
  }

  // ─── Wallet ─────────────────────────────────────────────────────────
  int _balanceFc = 45800;
  int get balanceFc => _balanceFc;
  double get balanceUsd => _balanceFc / _usdToCdf;

  /// Monthly top-up ceiling and how much of it has been used this month.
  /// Surfaced as "Monthly Remaining Limit" on the Add money screen and used
  /// to validate a requested top-up.
  final int _monthlyTopUpLimitFc = 2000000;
  int _monthlyToppedUpFc = 291766;

  /// FC the customer may still top up this month.
  int get monthlyTopUpRemainingFc =>
      (_monthlyTopUpLimitFc - _monthlyToppedUpFc).clamp(0, _monthlyTopUpLimitFc);

  final List<PaymentMethod> _methods = <PaymentMethod>[
    const PaymentMethod(icon: Icons.smartphone, label: 'Orange Money', sub: '+243 89 *** **45'),
    const PaymentMethod(icon: Icons.smartphone, label: 'Airtel Money', sub: '+243 99 *** **12'),
    const PaymentMethod(icon: Icons.credit_card, label: 'Visa', sub: '•••• 4242'),
    const PaymentMethod(icon: Icons.payments, label: 'Cash on delivery', sub: 'Pay the driver'),
  ];
  List<PaymentMethod> get paymentMethods => List.unmodifiable(_methods);

  final List<WalletTx> _transactions = <WalletTx>[
    const WalletTx(label: 'Maison Kinshasa', amountFc: -12500, sub: 'Today · 19:42', icon: Icons.restaurant),
    const WalletTx(label: 'Wallet top-up', amountFc: 25000, sub: 'Yesterday · 09:11', icon: Icons.add),
    const WalletTx(label: 'Le Grill Premium', amountFc: -18200, sub: 'May 20 · 20:30', icon: Icons.restaurant),
    const WalletTx(label: 'Referral bonus', amountFc: 5000, sub: 'May 18 · 14:02', icon: Icons.card_giftcard),
  ];
  List<WalletTx> get transactions => List.unmodifiable(_transactions);

  /// Add [fc] to the wallet via [method]. Returns false (without mutating)
  /// when the amount is invalid or would exceed the monthly top-up limit.
  bool topUp(int fc, {required String method}) {
    if (fc <= 0 || fc > monthlyTopUpRemainingFc) return false;
    _balanceFc += fc;
    _monthlyToppedUpFc += fc;
    _transactions.insert(0, WalletTx(
      label: 'Wallet top-up',
      amountFc: fc,
      sub: 'Just now · $method',
      icon: Icons.add,
    ));
    notifyListeners();
    return true;
  }

  /// Send credit to another user. Returns false if the wallet can't cover it.
  bool sendCredit({required int fc, required String recipient}) {
    if (fc <= 0 || fc > _balanceFc) return false;
    _balanceFc -= fc;
    _transactions.insert(0, WalletTx(
      label: 'Sent to $recipient',
      amountFc: -fc,
      sub: 'Just now · Transfer',
      icon: Icons.send,
    ));
    notifyListeners();
    return true;
  }

  void addPaymentMethod(PaymentMethod method) {
    _methods.add(method);
    notifyListeners();
  }
}
