import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../app/theme.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KlinikaSpacing.md,
          vertical: KlinikaSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: KlinikaPalette.inkLight,
          borderRadius: KlinikaRadius.md,
          border: Border.all(color: KlinikaPalette.inkBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Gemini construit votre fiche',
              style: TextStyle(
                color: KlinikaPalette.mist,
                fontSize: 13,
              ),
            ),
            const Gap(KlinikaSpacing.sm),
            ...List.generate(3, (index) {
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  color: KlinikaPalette.emerald,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(delay: (index * 150).ms, duration: 300.ms)
                  .then()
                  .fadeOut(duration: 300.ms);
            }),
          ],
        ),
      ),
    );
  }
}
