import 'package:flutter/material.dart';

class TableActionButton {
  final Widget? icon;
  final Widget child;
  final SingleActivator? shortcuts;
  final Color? bgColor, fgColor;
  final Function() onTap;

  TableActionButton({
    this.icon,
    required this.child,
    this.bgColor,
    this.fgColor,
    this.shortcuts,
    required this.onTap,
  });
}
