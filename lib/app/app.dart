import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class KlinikaApp extends StatelessWidget {
  const KlinikaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'klinika_ai',
      debugShowCheckedModeBanner: false,
      theme: buildKlinikaTheme(),
      routerConfig: router,
    );
  }
}
