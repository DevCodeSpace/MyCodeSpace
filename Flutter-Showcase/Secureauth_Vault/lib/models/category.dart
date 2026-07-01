import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final int color;
  final String type;

  const Category({required this.id, required this.name, required this.icon, required this.color, required this.type});

  Color get displayColor => Color(color);

  IconData get displayIcon {
    switch (icon) {
      case 'lock':
        return Icons.lock_outline;
      case 'email':
        return Icons.email_outlined;
      case 'account_balance':
        return Icons.account_balance_outlined;
      case 'wifi':
        return Icons.wifi;
      case 'vpn_key':
        return Icons.vpn_key_outlined;
      case 'note':
        return Icons.note_outlined;
      case 'badge':
        return Icons.badge_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'medical_services':
        return Icons.medical_services_outlined;
      case 'workspace_premium':
        return Icons.workspace_premium_outlined;
      case 'folder':
        return Icons.folder_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'icon': icon, 'color': color, 'type': type};

  factory Category.fromMap(Map<String, dynamic> map) =>
      Category(id: map['id'] as String, name: map['name'] as String, icon: map['icon'] as String, color: map['color'] as int, type: map['type'] as String);

  Category copyWith({String? name, String? icon, int? color}) => Category(id: id, name: name ?? this.name, icon: icon ?? this.icon, color: color ?? this.color, type: type);
}
