import 'package:flutter/material.dart';

class ScreenWrapper extends StatelessWidget {
  final Widget child;
  final double padding;

  const ScreenWrapper({
    super.key,
    required this.child,
    this.padding = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: child,
    );
  }
}
