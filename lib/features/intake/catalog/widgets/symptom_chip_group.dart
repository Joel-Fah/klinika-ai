import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../app/theme.dart';

final symptomChipGroupSchema = S.object(
  properties: {
    'label': S.string(description: 'Section label in the patient language'),
    'chips': S.list(
      items: S.string(description: 'A symptom chip label'),
      description: 'List of symptom options to display',
    ),
  },
  required: ['label', 'chips'],
);

CatalogItem buildSymptomChipGroupItem() {
  return CatalogItem(
    name: 'SymptomChipGroup',
    dataSchema: symptomChipGroupSchema,
    widgetBuilder: (itemContext) {
      final data = itemContext.data as Map<String, Object?>;

      return StreamBuilder<Object?>(
        stream: itemContext.dataContext.resolve(data['label']),
        builder: (context, labelSnapshot) {
          return StreamBuilder<Object?>(
            stream: itemContext.dataContext.resolve(data['chips']),
            builder: (context, chipsSnapshot) {
              final label = labelSnapshot.data?.toString();
              final chips = (chipsSnapshot.data as List?)
                      ?.map((value) => value.toString())
                      .toList() ??
                  [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(
                      label,
                      style: const TextStyle(
                        color: KlinikaPalette.mist,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const Gap(KlinikaSpacing.sm),
                  Wrap(
                    spacing: KlinikaSpacing.sm,
                    runSpacing: KlinikaSpacing.sm,
                    children: chips
                        .map(
                          (chip) => ActionChip(
                            label: Text(chip),
                            onPressed: () {},
                            backgroundColor: KlinikaPalette.inkMid,
                            side: const BorderSide(
                              color: KlinikaPalette.inkBorder,
                            ),
                            labelStyle: const TextStyle(
                              color: KlinikaPalette.snowWhite,
                              fontSize: 13,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms);
            },
          );
        },
      );
    },
  );
}
