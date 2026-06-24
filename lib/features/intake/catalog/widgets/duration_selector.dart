import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../app/theme.dart';

final durationSelectorSchema = S.object(
  properties: {
    'label': S.any(description: 'Question label in the patient language'),
    'value': S.any(description: 'Data binding path for the selected duration'),
    'options': S.list(
      description: 'Duration options to show',
      items: S.object(
        properties: {
          'label': S.string(),
          'value': S.string(),
        },
        required: ['label', 'value'],
      ),
    ),
  },
  required: ['label', 'value', 'options'],
);

CatalogItem buildDurationSelectorItem() {
  return CatalogItem(
    name: 'DurationSelector',
    dataSchema: durationSelectorSchema,
    widgetBuilder: (itemContext) {
      final data = itemContext.data as Map<String, Object?>;
      final path = _pathFor(data['value'], '${itemContext.id}.value');
      final options = (data['options'] as List?)
              ?.whereType<Map>()
              .map((option) => Map<String, Object?>.from(option))
              .toList() ??
          const <Map<String, Object?>>[];

      return StreamBuilder<Object?>(
        stream: itemContext.dataContext.resolve(data['label']),
        builder: (context, labelSnapshot) {
          return StreamBuilder<String?>(
            stream: itemContext.dataContext.subscribeStream<String>(
              DataPath(path),
            ),
            builder: (context, selectedSnapshot) {
              final selected = selectedSnapshot.data;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelSnapshot.data?.toString() ?? 'Duration',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const Gap(KlinikaSpacing.sm),
                  Wrap(
                    spacing: KlinikaSpacing.sm,
                    runSpacing: KlinikaSpacing.sm,
                    children: options.map((option) {
                      final label = option['label']?.toString() ?? '';
                      final value = option['value']?.toString() ?? label;
                      final isSelected = selected == value;

                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          itemContext.dataContext.update(
                            DataPath(path),
                            value,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
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
