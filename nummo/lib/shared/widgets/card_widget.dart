import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CardWidget({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}

