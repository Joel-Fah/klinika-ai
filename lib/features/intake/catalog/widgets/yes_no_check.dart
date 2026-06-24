import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../app/theme.dart';

final yesNoCheckSchema = S.object(
  properties: {
    'label': S.any(description: 'Question label in the patient language'),
    'value': S.any(description: 'Data binding path for the selected answer'),
    'yesLabel': S.string(description: 'Optional yes label'),
    'noLabel': S.string(description: 'Optional no label'),
    'unknownLabel': S.string(description: 'Optional unknown/not checked label'),
  },
  required: ['label', 'value'],
);

CatalogItem buildYesNoCheckItem() {
  return CatalogItem(
    name: 'YesNoCheck',
    dataSchema: yesNoCheckSchema,
    widgetBuilder: (itemContext) {
      final data = itemContext.data as Map<String, Object?>;
      final path = _pathFor(data['value'], '${itemContext.id}.value');
      final answers = [
        (data['yesLabel']?.toString() ?? 'Yes', 'yes'),
        (data['noLabel']?.toString() ?? 'No', 'no'),
        (data['unknownLabel']?.toString() ?? 'Not sure', 'unknown'),
      ];

      return StreamBuilder<Object?>(
        stream: itemContext.dataContext.resolve(data['label']),
        builder: (context, labelSnapshot) {
          return StreamBuilder<String?>(
            stream: itemContext.dataContext.subscribeStream<String>(
              DataPath(path),
            ),
            builder: (context, selectedSnapshot) {
              final selected = selectedSnapshot.data;

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
                        labelSnapshot.data?.toString() ?? 'Check',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const Gap(KlinikaSpacing.md),
                      Row(
                        children: answers.map((answer) {
                          final isSelected = selected == answer.$2;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: KlinikaSpacing.sm,
                              ),
                              child: _AnswerButton(
                                label: answer.$1,
                                selected: isSelected,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  itemContext.dataContext.update(
                                    DataPath(path),
                                    answer.$2,
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
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

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? KlinikaPalette.emerald : KlinikaPalette.inkMid,
      shape: KlinikaShapes.md,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: KlinikaSpacing.md),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color:
                      selected ? KlinikaPalette.ink : KlinikaPalette.snowWhite,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

String _pathFor(Object? value, String fallback) {
  if (value case {'path': final String path}) return path;
  return fallback;
}
