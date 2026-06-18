import 'package:flutter/material.dart';

class DeviceCategoryInfo {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int order;

  /// Поддерживается для квартиры
  final bool supportsApartment;

  /// Поддерживается для дома
  final bool supportsHouse;

  const DeviceCategoryInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.order,
    this.supportsApartment = true,
    this.supportsHouse = true,
  });
}