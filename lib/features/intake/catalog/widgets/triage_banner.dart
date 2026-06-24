import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/strings.dart';

final triageBannerSchema = S.object(
  properties: {
    'severity': S.string(
      description: 'Urgency level: urgent | moderate | routine',
      enumValues: ['urgent', 'moderate', 'routine'],
    ),
    'message': S.string(
      description:
          'A short message explaining the triage level in the patient language',
    ),
  },
  required: ['severity', 'message'],
);

CatalogItem buildTriageBannerItem() {
  return CatalogItem(
    name: 'TriageBanner',
    dataSchema: triageBannerSchema,
    widgetBuilder: (itemContext) {
      final data = itemContext.data as Map<String, Object?>;

      return StreamBuilder<Object?>(
        stream: itemContext.dataContext.resolve(data['severity']),
        builder: (context, severitySnapshot) {
          return StreamBuilder<Object?>(
            stream: itemContext.dataContext.resolve(data['message']),
            builder: (context, messageSnapshot) {
              final severity = severitySnapshot.data?.toString();
              final message = messageSnapshot.data?.toString() ?? '';
              final color = switch (severity) {
                'urgent' => KlinikaPalette.urgent,
                'moderate' => KlinikaPalette.moderate,
                _ => KlinikaPalette.routine,
              };
              final label = switch (severity) {
                'urgent' => KlinikaStrings.urgent,
                'moderate' => KlinikaStrings.moderate,
                _ => KlinikaStrings.routine,
              };

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: KlinikaSpacing.md,
                  vertical: KlinikaSpacing.sm + 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: KlinikaRadius.md,
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(KlinikaSpacing.sm),
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(KlinikaSpacing.md),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: KlinikaPalette.snowWhite,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
            },
          );
        },
      );
    },
  );
}
