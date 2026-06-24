import 'package:flutter/material.dart';

class KlinikaButton extends StatelessWidget {
  const KlinikaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return ElevatedButton(onPressed: onPressed, child: Text(label));
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon!,
      label: Text(label),
    );
  }
}
