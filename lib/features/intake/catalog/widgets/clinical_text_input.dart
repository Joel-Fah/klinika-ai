import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../app/theme.dart';

final clinicalTextInputSchema = S.object(
  properties: {
    'label': S.any(description: 'Question label in the patient language'),
    'value': S.any(description: 'Data binding path for the entered text'),
    'placeholder': S.string(description: 'Optional input hint'),
    'submitLabel': S.string(description: 'Optional tooltip for submit'),
  },
  required: ['label', 'value'],
);

CatalogItem buildClinicalTextInputItem() {
  return CatalogItem(
    name: 'ClinicalTextInput',
    dataSchema: clinicalTextInputSchema,
    widgetBuilder: (itemContext) {
      final data = itemContext.data as Map<String, Object?>;
      final path = _pathFor(data['value'], '${itemContext.id}.value');
      final placeholder = data['placeholder']?.toString();
      final submitLabel = data['submitLabel']?.toString() ?? 'Continue';

      return StreamBuilder<Object?>(
        stream: itemContext.dataContext.resolve(data['label']),
        builder: (context, labelSnapshot) {
          return StreamBuilder<Object?>(
            stream: itemContext.dataContext.resolve(data['value']),
            builder: (context, valueSnapshot) {
              return _ClinicalTextInput(
                itemContext: itemContext,
                path: path,
                initialValue: valueSnapshot.data?.toString() ?? '',
                label: labelSnapshot.data?.toString() ?? 'Follow-up',
                placeholder: placeholder,
                submitLabel: submitLabel,
              );
            },
          );
        },
      );
    },
  );
}

class _ClinicalTextInput extends StatefulWidget {
  const _ClinicalTextInput({
    required this.itemContext,
    required this.path,
    required this.initialValue,
    required this.label,
    required this.placeholder,
    required this.submitLabel,
  });

  final CatalogItemContext itemContext;
  final String path;
  final String initialValue;
  final String label;
  final String? placeholder;
  final String submitLabel;

  @override
  State<_ClinicalTextInput> createState() => _ClinicalTextInputState();
}

class _ClinicalTextInputState extends State<_ClinicalTextInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _ClinicalTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    widget.itemContext.dataContext.update(DataPath(widget.path), text);
    widget.itemContext.dispatchEvent(
      UserActionEvent(
        surfaceId: widget.itemContext.surfaceId,
        name: 'continue_intake',
        sourceComponentId: widget.itemContext.id,
        context: {
          'field': widget.itemContext.id,
          'value': text,
          'path': widget.path,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
            const Gap(KlinikaSpacing.sm),
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onChanged: (value) {
                widget.itemContext.dataContext.update(
                  DataPath(widget.path),
                  value,
                );
              },
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                suffixIcon: Tooltip(
                  message: widget.submitLabel,
                  child: IconButton(
                    onPressed: _submit,
                    icon: const Icon(HugeIcons.strokeRoundedSent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _pathFor(Object? value, String fallback) {
  if (value case {'path': final String path}) return path;
  return fallback;
}
