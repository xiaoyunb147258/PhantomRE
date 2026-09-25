import 'package:flutter/material.dart';

class ToolItem {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final String route;
  const ToolItem({required this.title, required this.desc, required this.icon,
    required this.color, required this.route});
}
