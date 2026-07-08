import 'package:flutter/foundation.dart';

import 'menu_item.dart';

/// A storefront the customer can browse. Used by search, categories, and
/// restaurant detail so a single source of seed data drives the whole flow.
@immutable
class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.district,
    required this.heroImage,
    required this.rating,
    required this.reviewCount,
    required this.etaMinutes,
    required this.deliveryFee,
    required this.priceLevel,
    required this.menu,
    this.tags = const [],
    this.freeDeliveryMinimum = 15.0,
  });

  final String id;
  final String name;
  final String cuisine;
  final String district;
  final String heroImage;
  final double rating;
  final int reviewCount;
  /// Lower bound of the ETA range in minutes; we display "${etaMinutes}–${etaMinutes+10} min".
  final int etaMinutes;
  final double deliveryFee;
  /// `$`, `$$`, or `$$$`.
  final String priceLevel;
  final List<MenuItem> menu;
  /// Lowercased category tags used for category / search filtering.
  final List<String> tags;
  /// Order subtotal (in USD) above which delivery is free for this restaurant.
  final double freeDeliveryMinimum;

  String get etaRange => '$etaMinutes–${etaMinutes + 10} min';
}

/// Seed catalogue used across home, search, categories, and the restaurant
/// detail page. Lives in-memory so the demo is self-contained.
class RestaurantCatalog {
  RestaurantCatalog._();

  static final List<Restaurant> all = [
    Restaurant(
      id: 'maison-kinshasa',
      name: 'Maison Kinshasa',
      cuisine: 'Congolese',
      district: 'Lingwala',
      heroImage: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1400&q=85',
      rating: 4.6,
      reviewCount: 820,
      etaMinutes: 15,
      deliveryFee: 2.00,
      priceLevel: '\$\$',
      tags: const ['congolese', 'african', 'local'],
      menu: const [
        MenuItem(
          id: 'mk-poulet-moambe',
          category: 'Signature Plates',
          name: 'Poulet Moambe',
          description: 'Palm-nut sauce, chikwangue, pondu',
          price: 12.50,
          image: 'https://images.unsplash.com/photo-1604908177453-7462950a6a3b?w=600&q=80',
          badge: '#1 THIS MONTH',
          featured: true,
          modifiers: [
            ModifierGroup(
              name: 'Spice level',
              required: true,
              options: [
                ModifierOption(name: 'Mild'),
                ModifierOption(name: 'Medium'),
                ModifierOption(name: 'Pili-pili hot'),
              ],
            ),
            ModifierGroup(
              name: 'Add sides',
              multiSelect: true,
              options: [
                ModifierOption(name: 'Extra pondu', priceDelta: 2.00),
                ModifierOption(name: 'Fufu', priceDelta: 1.50),
                ModifierOption(name: 'Fried plantains', priceDelta: 2.00),
                ModifierOption(name: 'Rice', priceDelta: 1.50),
              ],
            ),
          ],
        ),
        MenuItem(
          id: 'mk-liboke-poisson',
          category: 'Signature Plates',
          name: 'Liboke de Poisson',
          description: 'Tilapia in banana leaf, pondu, rice',
          price: 9.50,
          image: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=600&q=80',
          badge: 'PAUL LOVED THIS',
        ),
        MenuItem(
          id: 'mk-capitaine-grille',
          category: 'Grills',
          name: 'Capitaine Grillé',
          description: 'Grilled Nile perch, mashed plantains',
          price: 22.00,
          image: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80',
        ),
        MenuItem(
          id: 'mk-bissap',
          category: 'Drinks',
          name: 'Bissap Fraîche',
          description: 'Hibiscus drink, served chilled',
          price: 2.50,
          image: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=600&q=80',
          badge: 'NEW',
        ),
      ],
    ),
    Restaurant(
      id: 'le-grill-premium',
      name: 'Le Grill Premium',
      cuisine: 'Steakhouse',
      district: 'Gombe',
      heroImage: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=1400&q=85',
      rating: 4.7,
      reviewCount: 412,
      etaMinutes: 25,
      deliveryFee: 3.00,
      priceLevel: '\$\$\$',
      tags: const ['steakhouse', 'burgers', 'grill'],
      menu: const [
        MenuItem(
          id: 'lgp-truffle-burger',
          category: 'Burgers',
          name: 'Truffle Mushroom Burger',
          description: 'Dry-aged beef patty, wild mushrooms, gruyère, truffle aioli',
          price: 18.50,
          image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=1200&q=85',
          badge: 'CHEF\'S PICK',
          featured: true,
          modifiers: [
            ModifierGroup(
              name: 'How would you like it cooked?',
              required: true,
              options: [
                ModifierOption(name: 'Medium rare'),
                ModifierOption(name: 'Medium'),
                ModifierOption(name: 'Well done'),
              ],
            ),
            ModifierGroup(
              name: 'Choose your side',
              required: true,
              options: [
                ModifierOption(name: 'Sea Salt Fries', priceDelta: 0),
                ModifierOption(name: 'Sweet Potato Fries', priceDelta: 1.50),
                ModifierOption(name: 'Side Salad', priceDelta: 2.00),
                ModifierOption(name: 'Onion Rings', priceDelta: 1.50),
              ],
            ),
            ModifierGroup(
              name: 'Add extras',
              multiSelect: true,
              maxSelect: 4,
              options: [
                ModifierOption(name: 'Smoked bacon', priceDelta: 2.00),
                ModifierOption(name: 'Extra gruyère', priceDelta: 1.50),
                ModifierOption(name: 'Fried egg', priceDelta: 1.00),
                ModifierOption(name: 'Avocado', priceDelta: 1.50),
                ModifierOption(name: 'Caramelised onions', priceDelta: 1.00),
              ],
            ),
          ],
        ),
        MenuItem(
          id: 'lgp-ribeye',
          category: 'From the Grill',
          name: 'Ribeye 300g',
          description: '40-day dry-aged, peppercorn jus, fries',
          price: 32.00,
          image: 'https://images.unsplash.com/photo-1546964124-0cce460f38ef?w=600&q=80',
        ),
        MenuItem(
          id: 'lgp-caesar',
          category: 'Salads',
          name: 'Caesar Salad',
          description: 'Cos, parmigiano, anchovies, croutons',
          price: 9.50,
          image: 'https://images.unsplash.com/photo-1551248429-40975aa4de74?w=600&q=80',
        ),
      ],
    ),
    Restaurant(
      id: 'sushi-lounge',
      name: 'Sushi Lounge',
      cuisine: 'Japanese',
      district: 'Limete',
      heroImage: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=1400&q=85',
      rating: 4.6,
      reviewCount: 287,
      etaMinutes: 25,
      deliveryFee: 3.50,
      priceLevel: '\$\$\$',
      tags: const ['sushi', 'japanese', 'asian'],
      menu: const [
        MenuItem(
          id: 'sl-dragon-roll',
          category: 'Signature Rolls',
          name: 'Dragon Roll',
          description: 'Eel, avocado, cucumber, eel sauce',
          price: 16.00,
          image: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=600&q=80',
          featured: true,
        ),
        MenuItem(
          id: 'sl-salmon-nigiri',
          category: 'Nigiri & Sashimi',
          name: 'Salmon Nigiri (5 pcs)',
          description: 'Fresh Atlantic salmon, sushi rice',
          price: 14.00,
          image: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=600&q=80',
        ),
        MenuItem(
          id: 'sl-edamame',
          category: 'Starters',
          name: 'Edamame',
          description: 'Sea-salt steamed pods',
          price: 4.50,
          image: 'https://images.unsplash.com/photo-1564834724105-918b73d1b9e0?w=600&q=80',
        ),
      ],
    ),
    Restaurant(
      id: 'pizzeria-napoli-gombe',
      name: 'Pizzeria Napoli Gombe',
      cuisine: 'Italian',
      district: 'Gombe',
      heroImage: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=1400&q=85',
      rating: 4.4,
      reviewCount: 690,
      etaMinutes: 18,
      deliveryFee: 2.50,
      priceLevel: '\$\$',
      tags: const ['pizza', 'italian'],
      menu: const [
        MenuItem(
          id: 'pn-margherita',
          category: 'Pizze',
          name: 'Margherita Grande',
          description: 'San marzano, fior di latte, basil, EVOO',
          price: 14.00,
          image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&q=80',
          featured: true,
          modifiers: [
            ModifierGroup(
              name: 'Size',
              required: true,
              options: [
                ModifierOption(name: 'Medium (30cm)'),
                ModifierOption(name: 'Large (36cm)', priceDelta: 4.00),
                ModifierOption(name: 'Family (45cm)', priceDelta: 8.00),
              ],
            ),
            ModifierGroup(
              name: 'Extra toppings',
              multiSelect: true,
              maxSelect: 5,
              options: [
                ModifierOption(name: 'Mushrooms', priceDelta: 1.50),
                ModifierOption(name: 'Spicy salami', priceDelta: 2.00),
                ModifierOption(name: 'Extra mozzarella', priceDelta: 2.00),
                ModifierOption(name: 'Black olives', priceDelta: 1.00),
                ModifierOption(name: 'Fresh rocket', priceDelta: 1.00),
              ],
            ),
          ],
        ),
        MenuItem(
          id: 'pn-quattro-formaggi',
          category: 'Pizze',
          name: 'Quattro Formaggi',
          description: 'Mozzarella, gorgonzola, parmesan, provola',
          price: 17.00,
          image: 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=600&q=80',
        ),
        MenuItem(
          id: 'pn-tiramisu',
          category: 'Dolci',
          name: 'Tiramisu',
          description: 'Mascarpone, espresso, cocoa',
          price: 6.00,
          image: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=600&q=80',
        ),
      ],
    ),
    Restaurant(
      id: 'mama-lina',
      name: 'Mama Lina',
      cuisine: 'Home-style Congolese',
      district: 'Bandalungwa',
      heroImage: 'https://images.unsplash.com/photo-1604908177453-7462950a6a3b?w=1400&q=85',
      rating: 4.9,
      reviewCount: 1240,
      etaMinutes: 20,
      deliveryFee: 1.50,
      priceLevel: '\$\$',
      tags: const ['congolese', 'local', 'comfort'],
      menu: const [
        MenuItem(
          id: 'ml-bissap',
          category: 'Drinks',
          name: 'Bissap Fraîche',
          description: 'Hibiscus, ginger, mint',
          price: 2.00,
          image: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=600&q=80',
        ),
        MenuItem(
          id: 'ml-plantains',
          category: 'Sides',
          name: 'Plantains Frits',
          description: 'Crisp ripe plantain, pili-pili dust',
          price: 4.00,
          image: 'https://images.unsplash.com/photo-1604908554007-c1aaef0e8caf?w=600&q=80',
        ),
      ],
    ),
  ];

  static Restaurant byId(String id) =>
      all.firstWhere((r) => r.id == id, orElse: () => all.first);

  static List<Restaurant> forTag(String tag) {
    final t = tag.toLowerCase();
    return all.where((r) => r.tags.any((x) => x.contains(t))).toList();
  }
}
