import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../app/theme.dart';

final painScaleSchema = S.object(
  properties: {
    'label': S.any(description: 'Question label in the patient language'),
    'value': S.any(description: 'Data binding path for the selected value'),
    'min': S.number(description: 'Minimum value, usually 0'),
    'max': S.number(description: 'Maximum value, usually 10'),
  },
  required: ['label', 'value'],
);

CatalogItem buildPainScaleItem() {
  return CatalogItem(
    name: 'PainScale',
    dataSchema: painScaleSchema,
    widgetBuilder: (itemContext) {
      final data = itemContext.data as Map<String, Object?>;
      final path = _pathFor(data['value'], '${itemContext.id}.value');
      final min = (data['min'] as num?)?.toDouble() ?? 0;
      final max = (data['max'] as num?)?.toDouble() ?? 10;

      return StreamBuilder<Object?>(
        stream: itemContext.dataContext.resolve(data['label']),
        builder: (context, labelSnapshot) {
          return StreamBuilder<num?>(
            stream: itemContext.dataContext.subscribeStream<num>(
              DataPath(path),
            ),
            builder: (context, valueSnapshot) {
              final value = (valueSnapshot.data ?? min).clamp(min, max);

              return DecoratedBox(
                decoration: ShapeDecoration(
                  color: KlinikaPalette.inkLight,
                  shape: KlinikaShapes.lg.copyWith(
                    side: const BorderSide(color: KlinikaPalette.inkBorder),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(KlinikaSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labelSnapshot.data?.toString() ?? 'Pain intensity',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const Gap(KlinikaSpacing.md),
                      Row(
                        children: [
                          Text(
                            value.round().toString(),
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(color: KlinikaPalette.emerald),
                          ),
                          const Gap(KlinikaSpacing.md),
                          Expanded(
                            child: Slider(
                              min: min,
                              max: max,
                              divisions: (max - min).round(),
                              value: value.toDouble(),
                              label: value.round().toString(),
                              onChanged: (next) {
                                HapticFeedback.selectionClick();
                                itemContext.dataContext.update(
                                  DataPath(path),
                                  next.round(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

String _pathFor(Object? value, String fallback) {
  if (value case {'path': final String path}) return path;
  return fallback;
}
