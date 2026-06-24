import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../app/theme.dart';

final departmentSelectorSchema = S.object(
  properties: {
    'department': S.string(
      description:
          'Clinical department in the patient language, for example Medecine Generale, Pediatrie, Urgences, ORL',
    ),
    'reason': S.string(
      description:
          'One short sentence explaining why this department is recommended',
    ),
  },
  required: ['department'],
);

CatalogItem buildDepartmentSelectorItem() {
  return CatalogItem(
    name: 'DepartmentSelector',
    dataSchema: departmentSelectorSchema,
    widgetBuilder: (itemContext) {
      final data = itemContext.data as Map<String, Object?>;

      return StreamBuilder<Object?>(
        stream: itemContext.dataContext.resolve(data['department']),
        builder: (context, departmentSnapshot) {
          return StreamBuilder<Object?>(
            stream: itemContext.dataContext.resolve(data['reason']),
            builder: (context, reasonSnapshot) {
              final department = departmentSnapshot.data?.toString();
              final reason = reasonSnapshot.data?.toString();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(KlinikaSpacing.md),
                decoration: BoxDecoration(
                  color: KlinikaPalette.emeraldSurface,
                  borderRadius: KlinikaRadius.md,
                  border: Border.all(color: KlinikaPalette.inkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service recommande',
                      style: TextStyle(
                        color: KlinikaPalette.emerald,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(KlinikaSpacing.xs),
                    Text(
                      department ?? '-',
                      style: const TextStyle(
                        color: KlinikaPalette.snowWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (reason != null && reason.isNotEmpty) ...[
                      const Gap(KlinikaSpacing.xs),
                      Text(
                        reason,
                        style: const TextStyle(
                          color: KlinikaPalette.mist,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).scale(
                    begin: const Offset(0.97, 0.97),
                  );
            },
          );
        },
      );
    },
  );
}
