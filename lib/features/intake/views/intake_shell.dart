import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/intake_controller.dart';

class IntakeShell extends StatelessWidget {
  const IntakeShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<IntakeController>()) {
      Get.put(IntakeController());
    }
    return child;
  }
}
