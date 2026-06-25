import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/strings.dart';

final careSummarySchema = S.object(
  properties: {
    'severity': S.string(
      description: 'Final urgency level: urgent | moderate | routine',
      enumValues: ['urgent', 'moderate', 'routine'],
    ),
    'title': S.string(description: 'Short final summary title'),
    'subtitle': S.string(description: 'One-sentence human explanation'),
    'department': S.string(description: 'Recommended clinical service'),
    'sections': S.list(
      description: 'Structured summary blocks',
      items: S.object(
        properties: {
          'heading': S.string(description: 'Section title'),
          'body': S.string(description: 'Section content'),
          'kind': S.string(
            description: 'summary | nextSteps | warning | reassurance',
            enumValues: ['summary', 'nextSteps', 'warning', 'reassurance'],
          ),
        },
        required: ['heading', 'body'],
      ),
    ),
    'disclaimer': S.string(description: 'Short intake safety disclaimer'),
  },
  required: ['severity', 'title', 'subtitle', 'department', 'sections'],
);

CatalogItem buildCareSummaryItem() {
  return CatalogItem(
    name: 'CareSummary',
    dataSchema: careSummarySchema,
    widgetBuilder: (itemContext) {
      final data = itemContext.data as Map<String, Object?>;
      final sections = (data['sections'] as List?)
              ?.whereType<Map>()
              .map((section) => Map<String, Object?>.from(section))
              .toList() ??
          const <Map<String, Object?>>[];

      return StreamBuilder<Object?>(
        stream: itemContext.dataContext.resolve(data['severity']),
        builder: (context, severitySnapshot) {
          return StreamBuilder<Object?>(
            stream: itemContext.dataContext.resolve(data['title']),
            builder: (context, titleSnapshot) {
              return StreamBuilder<Object?>(
                stream: itemContext.dataContext.resolve(data['subtitle']),
                builder: (context, subtitleSnapshot) {
                  return StreamBuilder<Object?>(
                    stream: itemContext.dataContext.resolve(data['department']),
                    builder: (context, departmentSnapshot) {
                      final severity =
                          severitySnapshot.data?.toString() ?? 'routine';
                      final color = _severityColor(severity);
                      final severityLabel = _severityLabel(severity);

                      return DecoratedBox(
                        decoration: ShapeDecoration(
                          color: KlinikaPalette.inkLight,
                          shape: KlinikaShapes.xl.copyWith(
                            side: BorderSide(
                              color: color.withValues(alpha: 0.36),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(KlinikaSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SummaryMark(color: color),
                                  const Gap(KlinikaSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _PriorityPill(
                                          color: color,
                                          label: severityLabel,
                                        ),
                                        const Gap(KlinikaSpacing.sm),
                                        Text(
                                          titleSnapshot.data?.toString() ??
                                              'Resume de prise en charge',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium,
                                        ),
                                        const Gap(KlinikaSpacing.xs),
                                        Text(
                                          subtitleSnapshot.data?.toString() ??
                                              '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(KlinikaSpacing.lg),
                              _DepartmentBlock(
                                department:
                                    departmentSnapshot.data?.toString() ?? '',
                                color: color,
                              ),
                              const Gap(KlinikaSpacing.md),
                              ...sections.map(
                                (section) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: KlinikaSpacing.sm,
                                  ),
                                  child: _SummarySection(section: section),
                                ),
                              ),
                              if (data['disclaimer'] != null) ...[
                                const Gap(KlinikaSpacing.sm),
                                Text(
                                  data['disclaimer'].toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: KlinikaPalette.mist),
                                ),
                              ],
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
        },
      );
    },
  );
}

class _SummaryMark extends StatelessWidget {
  const _SummaryMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.16),
        shape: KlinikaShapes.lg,
      ),
      child: SizedBox(
        width: 58,
        height: 58,
        child: Center(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedClipboard,
            color: color,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.14),
        shape: KlinikaShapes.sm.copyWith(
          side: BorderSide(color: color.withValues(alpha: 0.32)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KlinikaSpacing.sm,
          vertical: KlinikaSpacing.xs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _DepartmentBlock extends StatelessWidget {
  const _DepartmentBlock({required this.department, required this.color});

  final String department;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: KlinikaPalette.inkMid,
        shape: KlinikaShapes.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(KlinikaSpacing.md),
        child: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedHospital01,
              color: color,
              size: 22,
            ),
            const Gap(KlinikaSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service recommande',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const Gap(KlinikaSpacing.xs),
                  Text(
                    department,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.section});

  final Map<String, Object?> section;

  @override
  Widget build(BuildContext context) {
    final kind = section['kind']?.toString() ?? 'summary';
    final color = _kindColor(kind);

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.08),
        shape: KlinikaShapes.lg.copyWith(
          side: BorderSide(color: color.withValues(alpha: 0.22)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KlinikaSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HugeIcon(icon: _kindIcon(kind), color: color, size: 20),
            const Gap(KlinikaSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['heading']?.toString() ?? '',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const Gap(KlinikaSpacing.xs),
                  Text(
                    section['body']?.toString() ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: KlinikaPalette.mist,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _severityColor(String severity) {
  return switch (severity) {
    'urgent' => KlinikaPalette.urgent,
    'moderate' => KlinikaPalette.moderate,
    _ => KlinikaPalette.routine,
  };
}

String _severityLabel(String severity) {
  return switch (severity) {
    'urgent' => KlinikaStrings.urgent,
    'moderate' => KlinikaStrings.moderate,
    _ => KlinikaStrings.routine,
  };
}

Color _kindColor(String kind) {
  return switch (kind) {
    'warning' => KlinikaPalette.urgent,
    'nextSteps' => KlinikaPalette.emerald,
    'reassurance' => KlinikaPalette.routine,
    _ => KlinikaPalette.moderate,
  };
}

IconData _kindIcon(String kind) {
  return switch (kind) {
    'warning' => HugeIcons.strokeRoundedAlert02,
    'nextSteps' => HugeIcons.strokeRoundedRoute01,
    'reassurance' => HugeIcons.strokeRoundedFavourite,
    _ => HugeIcons.strokeRoundedNote,
  };
}
