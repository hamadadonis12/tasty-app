import 'package:flutter/material.dart';

// Admin
import '../screens/admin/command_center_overview_screen.dart';
import '../screens/admin/dispatch_fleet_command_screen.dart';
import '../screens/admin/financial_intelligence_screen.dart';
import '../screens/admin/logistics_command_screen.dart';
import '../screens/admin/logistics_financials_screen.dart';
import '../screens/admin/logistics_fleet_screen.dart';
import '../screens/admin/logistics_live_orders_screen.dart';
// Customer
import '../screens/customer/account_profile_screen.dart';
import '../screens/customer/chat_with_driver_screen.dart';
import '../screens/customer/checkout_payment_screen.dart';
import '../screens/customer/coupon_wallet_screen.dart';
import '../screens/customer/customize_order_screen.dart';
import '../screens/customer/delivery_address_setup_screen.dart';
import '../screens/customer/design_system_screen.dart';
import '../screens/customer/explore_categories_screen.dart';
import '../screens/customer/explore_tastylife_screen.dart';
import '../screens/customer/help_support_screen.dart';
import '../screens/customer/immersive_home_screen.dart';
import '../screens/customer/kinshasa_luxe_screen.dart';
import '../screens/customer/live_order_tracking_screen.dart';
import '../screens/customer/login_verification_screen.dart';
import '../screens/customer/loyalty_rewards_screen.dart';
import '../screens/customer/my_favorites_screen.dart';
import '../screens/customer/notifications_screen.dart';
import '../screens/customer/order_history_screen.dart';
import '../screens/customer/order_pickup_verification_screen.dart';
import '../screens/customer/order_success_celebration_screen.dart';
import '../screens/customer/permissions_onboarding_screen.dart';
import '../screens/customer/project_overview_screen.dart';
import '../screens/customer/proof_of_delivery_screen.dart';
import '../screens/customer/rate_experience_screen.dart';
import '../screens/customer/restaurant_detail_screen.dart';
import '../screens/customer/schedule_order_screen.dart';
import '../screens/customer/select_language_screen.dart';
import '../screens/customer/smart_search_screen.dart';
import '../screens/customer/splash_screen_1.dart';
import '../screens/customer/splash_screen_2.dart';
import '../screens/customer/wallet_payments_screen.dart';
// Restaurant
import '../screens/restaurant/inventory_manager_screen.dart';
import '../screens/restaurant/kitchen_os_live_orders_screen.dart';
import '../screens/restaurant/kitchen_os_order_queue_screen.dart';
import '../screens/restaurant/menu_manager_screen.dart';
import '../screens/restaurant/staff_productivity_screen.dart';
// Driver
import '../screens/driver/driver_command_center_screen.dart';
import '../screens/driver/driver_dashboard_screen.dart';
import '../screens/driver/earnings_performance_screen.dart';
import '../screens/driver/incoming_order_offer_screen.dart';
import '../screens/driver/new_order_offer_screen.dart';
import '../screens/driver/shift_streak_manager_screen.dart';
import '../screens/driver/tactical_navigation_screen.dart';

enum AppSurface { customer, driver, restaurant, admin }

enum ScreenStatus { live, wip, missing }

class ScreenEntry {
  const ScreenEntry({
    required this.slug,
    required this.title,
    required this.surface,
    required this.status,
    this.builder,
  });
  final String slug;
  final String title;
  final AppSurface surface;
  final ScreenStatus status;
  final WidgetBuilder? builder;
}

/// 50-screen Stitch catalog with builders wired for every implemented
/// screen. Anything still `wip` lives in the legacy `main.dart` prototype.
final List<ScreenEntry> screenCatalog = [
  // ---------- Customer ----------
  ScreenEntry(slug: 'tastylife_splash_screen_1', title: 'Splash 1', surface: AppSurface.customer,
      status: ScreenStatus.live, builder: (_) => const SplashScreen1()),
  ScreenEntry(slug: 'tastylife_splash_screen_2', title: 'Splash 2', surface: AppSurface.customer,
      status: ScreenStatus.live, builder: (_) => const SplashScreen2()),
  ScreenEntry(slug: 'permissions_onboarding', title: 'Permissions Onboarding',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const PermissionsOnboardingScreen()),
  ScreenEntry(slug: 'select_language', title: 'Select Language',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const SelectLanguageScreen()),
  ScreenEntry(slug: 'login_verification', title: 'Login + OTP',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const LoginVerificationScreen()),
  ScreenEntry(slug: 'delivery_address_setup', title: 'Delivery Address Setup',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const DeliveryAddressSetupScreen()),
  ScreenEntry(slug: 'immersive_home_experience', title: 'Immersive Home',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const ImmersiveHomeScreen()),
  ScreenEntry(slug: 'immersive_home_dark_mode', title: 'Immersive Home — Dark',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => Theme(
            data: ThemeData.dark(useMaterial3: true),
            child: const ImmersiveHomeScreen(),
          )),
  ScreenEntry(slug: 'explore_categories', title: 'Explore Categories',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const ExploreCategoriesScreen()),
  ScreenEntry(slug: 'explore_tastylife', title: 'Explore TastyLife (Editorial)',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const ExploreTastyLifeScreen()),
  ScreenEntry(slug: 'smart_search_experience', title: 'Smart Search',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const SmartSearchScreen()),
  ScreenEntry(slug: 'my_favorites', title: 'My Favorites',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const MyFavoritesScreen()),
  ScreenEntry(slug: 'restaurant_detail', title: 'Restaurant Detail',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const RestaurantDetailScreen()),
  ScreenEntry(slug: 'customize_your_order', title: 'Customize Your Order',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const CustomizeOrderScreen()),
  ScreenEntry(slug: 'checkout_payment', title: 'Checkout & Payment',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const CheckoutPaymentScreen()),
  ScreenEntry(slug: 'order_success_celebration', title: 'Order Success',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const OrderSuccessCelebrationScreen()),
  ScreenEntry(slug: 'live_order_tracking', title: 'Live Order Tracking',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const LiveOrderTrackingScreen()),
  ScreenEntry(slug: 'order_pickup_verification', title: 'Order Pickup Verification',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const OrderPickupVerificationScreen()),
  ScreenEntry(slug: 'proof_of_delivery', title: 'Proof of Delivery',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const ProofOfDeliveryScreen()),
  ScreenEntry(slug: 'rate_your_experience', title: 'Rate Your Experience',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const RateExperienceScreen()),
  ScreenEntry(slug: 'order_history_reorder', title: 'Order History + Reorder',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const OrderHistoryScreen()),
  ScreenEntry(slug: 'loyalty_rewards_hub', title: 'Loyalty & Rewards Hub',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const LoyaltyRewardsScreen()),
  ScreenEntry(slug: 'wallet_payments', title: 'Wallet & Payments',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const WalletPaymentsScreen()),
  ScreenEntry(slug: 'notifications_updates', title: 'Notifications',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const NotificationsScreen()),
  ScreenEntry(slug: 'help_support', title: 'Help & Support',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const HelpSupportScreen()),
  ScreenEntry(slug: 'account_profile', title: 'Account Profile',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const AccountProfileScreen()),
  ScreenEntry(slug: 'kinshasa_luxe_delivery', title: 'Kinshasa Luxe Delivery',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const KinshasaLuxeScreen()),

  // ---------- Driver ----------
  ScreenEntry(slug: 'driver_dashboard_fleet_one', title: 'Driver Dashboard',
      surface: AppSurface.driver, status: ScreenStatus.live,
      builder: (_) => const DriverDashboardScreen()),
  ScreenEntry(slug: 'driver_command_center', title: 'Driver Command Center',
      surface: AppSurface.driver, status: ScreenStatus.live,
      builder: (_) => const DriverCommandCenterScreen()),
  ScreenEntry(slug: 'incoming_order_offer', title: 'Incoming Order Offer',
      surface: AppSurface.driver, status: ScreenStatus.live,
      builder: (_) => const IncomingOrderOfferScreen()),
  ScreenEntry(slug: 'new_order_offer', title: 'New Order Offer',
      surface: AppSurface.driver, status: ScreenStatus.live,
      builder: (_) => const NewOrderOfferScreen()),
  ScreenEntry(slug: 'tactical_navigation_mode', title: 'Tactical Navigation',
      surface: AppSurface.driver, status: ScreenStatus.live,
      builder: (_) => const TacticalNavigationScreen()),
  ScreenEntry(slug: 'earnings_performance', title: 'Earnings & Performance',
      surface: AppSurface.driver, status: ScreenStatus.live,
      builder: (_) => const EarningsPerformanceScreen()),
  ScreenEntry(slug: 'shift_streak_manager', title: 'Shift & Streak Manager',
      surface: AppSurface.driver, status: ScreenStatus.live,
      builder: (_) => const ShiftStreakManagerScreen()),

  // ---------- Restaurant (Kitchen OS) ----------
  ScreenEntry(slug: 'kitchen_os_live_orders', title: 'Kitchen OS Live Orders',
      surface: AppSurface.restaurant, status: ScreenStatus.live,
      builder: (_) => const KitchenOsLiveOrdersScreen()),
  ScreenEntry(slug: 'kitchen_os_order_queue', title: 'Kitchen OS Order Queue',
      surface: AppSurface.restaurant, status: ScreenStatus.live,
      builder: (_) => const KitchenOsOrderQueueScreen()),
  ScreenEntry(slug: 'inventory_menu_manager', title: 'Inventory & Menu Manager',
      surface: AppSurface.restaurant, status: ScreenStatus.live,
      builder: (_) => const MenuManagerScreen()),
  ScreenEntry(slug: 'menu_inventory_manager', title: 'Menu Inventory Manager',
      surface: AppSurface.restaurant, status: ScreenStatus.live,
      builder: (_) => const InventoryManagerScreen()),
  ScreenEntry(slug: 'staff_productivity_center', title: 'Staff Productivity Center',
      surface: AppSurface.restaurant, status: ScreenStatus.live,
      builder: (_) => const StaffProductivityScreen()),

  // ---------- Admin (LogisAFRICA) ----------
  ScreenEntry(slug: 'command_center_overview', title: 'Command Center Overview',
      surface: AppSurface.admin, status: ScreenStatus.live,
      builder: (_) => const CommandCenterOverviewScreen()),
  ScreenEntry(slug: 'logistics_command', title: 'Logistics Command',
      surface: AppSurface.admin, status: ScreenStatus.live,
      builder: (_) => const LogisticsCommandScreen()),
  ScreenEntry(slug: 'logistics_command_live_orders', title: 'Logistics — Live Orders',
      surface: AppSurface.admin, status: ScreenStatus.live,
      builder: (_) => const LogisticsLiveOrdersScreen()),
  ScreenEntry(slug: 'logistics_command_fleet_overview', title: 'Logistics — Fleet Overview',
      surface: AppSurface.admin, status: ScreenStatus.live,
      builder: (_) => const LogisticsFleetScreen()),
  ScreenEntry(slug: 'logistics_command_financials', title: 'Logistics — Financials',
      surface: AppSurface.admin, status: ScreenStatus.live,
      builder: (_) => const LogisticsFinancialsScreen()),
  ScreenEntry(slug: 'dispatch_fleet_command', title: 'Dispatch Fleet Command',
      surface: AppSurface.admin, status: ScreenStatus.live,
      builder: (_) => const DispatchFleetCommandScreen()),
  ScreenEntry(slug: 'financial_intelligence_risk', title: 'Financial Intelligence & Risk',
      surface: AppSurface.admin, status: ScreenStatus.live,
      builder: (_) => const FinancialIntelligenceScreen()),

  // ---------- v2 design additions ----------
  ScreenEntry(slug: 'chat_with_driver', title: 'Chat with Driver',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const ChatWithDriverScreen()),
  ScreenEntry(slug: 'schedule_order', title: 'Schedule Order',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const ScheduleOrderScreen()),
  ScreenEntry(slug: 'coupon_wallet', title: 'Coupon Wallet',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const CouponWalletScreen()),

  // ---------- Reference ----------
  ScreenEntry(slug: 'tastylife_design_system_ui_kit', title: 'Design System UI Kit',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const DesignSystemScreen()),
  ScreenEntry(slug: 'project_overview_showcase', title: 'Project Overview Showcase',
      surface: AppSurface.customer, status: ScreenStatus.live,
      builder: (_) => const ProjectOverviewScreen()),
];
