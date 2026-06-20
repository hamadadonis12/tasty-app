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
    this.multiSelect = false,
    this.maxSelect,
  });
  final String name;
  final List<ModifierOption> options;

  /// Single-select groups (radios) with [required] true always keep one option
  /// chosen. Ignored for [multiSelect] groups.
  final bool required;

  /// When true the group renders as checkboxes — the customer can pick zero or
  /// more add-ons, each adding its [ModifierOption.priceDelta] to the total.
  final bool multiSelect;

  /// Optional cap on how many options a [multiSelect] group accepts. Null = no
  /// limit. Once the cap is hit, unchecked options disable.
  final int? maxSelect;
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
