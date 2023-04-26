import 'package:flutter/material.dart';

class RowActionButton {
  final IconData icon;
  final String? tooltip;
  final Color? color;
  final bool? Function(int index)? isDisabled;
  final Function(int index) onTap;

  RowActionButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.color,
    this.isDisabled,
  });
}
