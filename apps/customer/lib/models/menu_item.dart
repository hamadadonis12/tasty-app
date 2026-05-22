import 'package:flutter/foundation.dart';

@immutable
class ModifierOption {
  const ModifierOption({required this.name, this.priceDelta = 0});
  final String name;
  final double priceDelta;
}

@immutable
class ModifierGroup {
  const ModifierGroup({
    required this.name,
    required this.options,
    this.required = false,
  });
  final String name;
  final List<ModifierOption> options;
  final bool required;
}

@immutable
class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.badge,
    this.featured = false,
    this.modifiers = const [],
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String? badge;
  final bool featured;
  final List<ModifierGroup> modifiers;
}
