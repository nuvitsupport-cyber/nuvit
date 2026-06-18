import 'package:flutter/material.dart';

class DeviceInfo {
  final String name;
  final String description;
  final IconData icon;
  final bool allowedInApartment;

  const DeviceInfo({
    required this.name,
    required this.description,
    required this.icon,
    this.allowedInApartment = true,
  });
}