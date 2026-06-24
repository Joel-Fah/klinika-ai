import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../app/theme.dart';
import '../../../core/constants/strings.dart';
import '../controllers/intake_controller.dart';

class SessionView extends StatelessWidget {
  const SessionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntakeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(KlinikaStrings.sessionTitle),
        actions: [
          Obx(
            () => controller.hasStarted.value
                ? IconButton(
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedRefresh,
                      color: KlinikaPalette.mist,
                      size: 20,
                    ),
                    tooltip: KlinikaStrings.newSession,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      controller.resetSession();
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (!controller.hasStarted.value) {
                  return const _EmptySessionState()
                      .animate()
                      .fadeIn(duration: 500.ms);
                }

                return ListView.separated(
                  controller: controller.chatScrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    KlinikaSpacing.md,
                    KlinikaSpacing.md,
                    KlinikaSpacing.md,
                    KlinikaSpacing.lg,
                  ),
                  itemCount: controller.surfaceIds.length +
                      controller.assistantMessages.length +
                      (controller.isLoading.value ? 1 : 0) +
                      (controller.errorMessage.value != null &&
                              !controller.isLoading.value
                          ? 1
                          : 0),
                  separatorBuilder: (_, __) => const Gap(KlinikaSpacing.md),
                  itemBuilder: (context, index) {
                    if (controller.isLoading.value &&
                        index ==
                            controller.surfaceIds.length +
                                controller.assistantMessages.length) {
                      return const _GeminiThinkingCard()
                          .animate()
                          .fadeIn(duration: 300.ms);
                    }

                    if (controller.errorMessage.value != null &&
                        !controller.isLoading.value &&
                        index ==
                            controller.surfaceIds.length +
                                controller.assistantMessages.length) {
                      return _ErrorFeedbackCard(
                        message: controller.errorMessage.value!,
                        onDismiss: controller.clearError,
                      ).animate().fadeIn(duration: 240.ms).slideY(begin: 0.08);
                    }

                    if (index >= controller.surfaceIds.length) {
                      final message = controller.assistantMessages[
                          index - controller.surfaceIds.length];
                      return _AssistantMessageCard(message: message)
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.08);
                    }

                    final id = controller.surfaceIds[index];
                    return _GeneratedSurfaceCard(
                      surfaceId: id,
                      locked: controller.lockedSurfaceIds.contains(id),
                      child: Surface(
                        surfaceContext:
                            controller.surfaceController.contextFor(id),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15);
                  },
                );
              }),
            ),
            Obx(
              () => AnimatedSwitcher(
                duration: 260.ms,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: controller.shouldHideMainInput.value
                    ? const _GeneratedInputHint()
                    : _InputBar(controller: controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedSurfaceCard extends StatelessWidget {
  const _GeneratedSurfaceCard({
    required this.surfaceId,
    required this.locked,
    required this.child,
  });

  final String surfaceId;
  final bool locked;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: locked,
          child: AnimatedOpacity(
            opacity: locked ? 0.72 : 1,
            duration: const Duration(milliseconds: 220),
            child: child,
          ),
        ),
        if (locked)
          Positioned(
            top: KlinikaSpacing.sm,
            right: KlinikaSpacing.sm,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: KlinikaPalette.emerald.withValues(alpha: 0.16),
                shape: KlinikaShapes.sm.copyWith(
                  side: BorderSide(
                    color: KlinikaPalette.emerald.withValues(alpha: 0.36),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KlinikaSpacing.sm,
                  vertical: KlinikaSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      color: KlinikaPalette.emerald,
                      size: 16,
                    ),
                    const Gap(KlinikaSpacing.xs),
                    Text(
                      'Envoye',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: KlinikaPalette.emerald,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AssistantMessageCard extends StatelessWidget {
  const _AssistantMessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: KlinikaPalette.inkLight,
        shape: KlinikaShapes.lg.copyWith(
          side: BorderSide(
            color: KlinikaPalette.emerald.withValues(alpha: 0.24),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KlinikaSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: ShapeDecoration(
                color: KlinikaPalette.emerald.withValues(alpha: 0.14),
                shape: KlinikaShapes.md,
              ),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedStethoscope02,
                    color: KlinikaPalette.emerald,
                    size: 22,
                  ),
                ),
              ),
            ),
            const Gap(KlinikaSpacing.md),
            Expanded(
              child: SelectableText(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: KlinikaPalette.snowWhite,
                      height: 1.38,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedInputHint extends StatelessWidget {
  const _GeneratedInputHint();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return DecoratedBox(
      key: const ValueKey('generated-input-hint'),
      decoration: const BoxDecoration(
        color: KlinikaPalette.ink,
        border: Border(top: BorderSide(color: KlinikaPalette.inkBorder)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          KlinikaSpacing.md,
          KlinikaSpacing.sm,
          KlinikaSpacing.md,
          KlinikaSpacing.md + bottomInset,
        ),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: KlinikaPalette.inkLight,
            shape: KlinikaShapes.lg.copyWith(
              side: BorderSide(
                color: KlinikaPalette.emerald.withValues(alpha: 0.28),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KlinikaSpacing.md,
              vertical: KlinikaSpacing.md,
            ),
            child: Row(
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedTouchInteraction01,
                  color: KlinikaPalette.emerald,
                  size: 20,
                ),
                const Gap(KlinikaSpacing.sm),
                Expanded(
                  child: Text(
                    'Completez la fiche generee ci-dessus',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: KlinikaPalette.mist,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySessionState extends StatefulWidget {
  const _EmptySessionState();

  @override
  State<_EmptySessionState> createState() => _EmptySessionStateState();
}

class _EmptySessionStateState extends State<_EmptySessionState> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _emptyPrompts.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = _emptyPrompts[_index];
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(KlinikaSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 520),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: DecoratedBox(
                key: ValueKey(prompt.title),
                decoration: ShapeDecoration(
                  color: prompt.color.withValues(alpha: 0.14),
                  shape: KlinikaShapes.xl.copyWith(
                    side: BorderSide(
                      color: prompt.color.withValues(alpha: 0.32),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: Center(
                    child: HugeIcon(
                      icon: prompt.icon,
                      color: prompt.color,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ),
            const Gap(KlinikaSpacing.lg),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              child: Text(
                prompt.title,
                key: ValueKey('${prompt.title}-title'),
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const Gap(KlinikaSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 92),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: _TypewriterText(
                  key: ValueKey(prompt.body),
                  text: prompt.body,
                  style: textTheme.bodyLarge?.copyWith(
                    color: KlinikaPalette.mist,
                  ),
                ),
              ),
            ),
            const Gap(KlinikaSpacing.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: KlinikaSpacing.sm,
              runSpacing: KlinikaSpacing.sm,
              children: prompt.examples
                  .map(
                    (example) => DecoratedBox(
                      decoration: ShapeDecoration(
                        color: KlinikaPalette.inkLight,
                        shape: KlinikaShapes.sm.copyWith(
                          side: const BorderSide(
                            color: KlinikaPalette.inkBorder,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KlinikaSpacing.md,
                          vertical: KlinikaSpacing.sm,
                        ),
                        child: Text(
                          example,
                          style: textTheme.labelMedium?.copyWith(
                            color: KlinikaPalette.snowWhite,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  static const _emptyPrompts = [
    _EmptyPrompt(
      title: 'Bonjour, on commence doucement.',
      body:
          'Decrivez ce que vous ressentez. Je vais construire une fiche courte, utile, et adaptee a votre situation.',
      icon: HugeIcons.strokeRoundedStethoscope02,
      color: KlinikaPalette.emerald,
      examples: ['Fievre depuis 3 jours', 'Maux de tete', 'Fatigue'],
    ),
    _EmptyPrompt(
      title: 'Tell me what is happening.',
      body:
          'Use your own words. The screen will change as we learn what matters for this patient.',
      icon: HugeIcons.strokeRoundedAiNetwork,
      color: KlinikaPalette.moderate,
      examples: ['Chest pain', 'Child with rash', 'Trouble breathing'],
    ),
    _EmptyPrompt(
      title: 'Parle comme tu sens, on va gerer.',
      body:
          'Francais, English, Camfranglais: dis seulement le probleme. La fiche suivra le contexte.',
      icon: HugeIcons.strokeRoundedLanguageSkill,
      color: KlinikaPalette.routine,
      examples: ['My pikin get rash', 'Na fever dey', 'Mal au ventre'],
    ),
  ];
}

class _EmptyPrompt {
  const _EmptyPrompt({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.examples,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final List<String> examples;
}

class _GeminiThinkingCard extends StatelessWidget {
  const _GeminiThinkingCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: KlinikaPalette.inkLight,
        shape: KlinikaShapes.lg.copyWith(
          side: BorderSide(
            color: KlinikaPalette.inkBorder.withValues(alpha: 0.55),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KlinikaSpacing.lg),
        child: Row(
          children: [
            const _MorphingGeminiMark(),
            const Gap(KlinikaSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gemini construit la fiche',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Gap(KlinikaSpacing.xs),
                  Text(
                    'Analyse des symptomes, triage, puis surface GenUI...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Gap(KlinikaSpacing.md),
                  const _FluidProgressLine(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MorphingGeminiMark extends StatefulWidget {
  const _MorphingGeminiMark();

  @override
  State<_MorphingGeminiMark> createState() => _MorphingGeminiMarkState();
}

class _MorphingGeminiMarkState extends State<_MorphingGeminiMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 74,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOutCubic.transform(_controller.value);
          final pulse = (t - 0.5).abs() * 2;
          final outerShape = ShapeBorder.lerp(
            const CircleBorder(),
            KlinikaShapes.xl,
            pulse,
          )!;
          final innerShape = ShapeBorder.lerp(
            KlinikaShapes.sm,
            const StarBorder.polygon(sides: 4, rotation: 0.78),
            1 - pulse,
          )!;

          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _controller.value * 6.28,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: outerShape,
                    gradient: SweepGradient(
                      colors: [
                        KlinikaPalette.emerald.withValues(alpha: 0.14),
                        KlinikaPalette.moderate.withValues(alpha: 0.32),
                        KlinikaPalette.routine.withValues(alpha: 0.4),
                        KlinikaPalette.emerald.withValues(alpha: 0.14),
                      ],
                    ),
                  ),
                  child: const SizedBox(width: 74, height: 74),
                ),
              ),
              DecoratedBox(
                decoration: ShapeDecoration(
                  shape: innerShape,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      KlinikaPalette.emerald.withValues(alpha: 0.96),
                      KlinikaPalette.snowWhite.withValues(alpha: 0.86),
                      KlinikaPalette.moderate.withValues(alpha: 0.86),
                    ],
                    stops: [0, (0.36 + t * 0.28).clamp(0.0, 1.0), 1],
                  ),
                ),
                child: SizedBox(
                  width: 36 + pulse * 12,
                  height: 36 + (1 - pulse) * 16,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FluidProgressLine extends StatefulWidget {
  const _FluidProgressLine();

  @override
  State<_FluidProgressLine> createState() => _FluidProgressLineState();
}

class _FluidProgressLineState extends State<_FluidProgressLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOutCubic.transform(_controller.value);
        return ClipPath(
          clipper: ShapeBorderClipper(shape: KlinikaShapes.sm),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  KlinikaPalette.inkMid,
                  KlinikaPalette.emerald.withValues(alpha: 0.36),
                  KlinikaPalette.moderate.withValues(alpha: 0.42),
                  KlinikaPalette.inkMid,
                ],
                stops: [
                  0,
                  (t * 0.45).clamp(0.0, 1.0),
                  (0.55 + t * 0.35).clamp(0.0, 1.0),
                  1,
                ],
              ),
            ),
            child: const SizedBox(height: 8, width: double.infinity),
          ),
        );
      },
    );
  }
}

class _ErrorFeedbackCard extends StatelessWidget {
  const _ErrorFeedbackCard({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: KlinikaPalette.urgent.withValues(alpha: 0.1),
        shape: KlinikaShapes.lg.copyWith(
          side: BorderSide(
            color: KlinikaPalette.urgent.withValues(alpha: 0.28),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KlinikaSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: ShapeDecoration(
                color: KlinikaPalette.urgent.withValues(alpha: 0.16),
                shape: KlinikaShapes.md,
              ),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedAlert02,
                    color: KlinikaPalette.urgent,
                    size: 22,
                  ),
                ),
              ),
            ),
            const Gap(KlinikaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'La fiche n a pas pu etre affichee',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Gap(KlinikaSpacing.xs),
                  Text(message, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedCancel01,
                color: KlinikaPalette.mist,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  const _TypewriterText({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  Timer? _timer;
  int _visibleCharacters = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant _TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    _visibleCharacters = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 34), (timer) {
      if (!mounted) return;
      if (_visibleCharacters >= widget.text.length) {
        timer.cancel();
        return;
      }
      setState(() => _visibleCharacters++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.substring(0, _visibleCharacters),
      style: widget.style,
      textAlign: TextAlign.center,
    );
  }
}

class _InputBar extends StatefulWidget {
  const _InputBar({required this.controller});

  final IntakeController controller;

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  final _focusNode = FocusNode();

  IntakeController get controller => widget.controller;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    controller.sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: KlinikaPalette.ink,
        border: Border(top: BorderSide(color: KlinikaPalette.inkBorder)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          KlinikaSpacing.md,
          KlinikaSpacing.sm,
          KlinikaSpacing.md,
          KlinikaSpacing.md + bottomInset,
        ),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: KlinikaPalette.inkLight,
            shape: KlinikaShapes.xl.copyWith(
              side: const BorderSide(color: KlinikaPalette.inkBorder),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              KlinikaSpacing.md,
              KlinikaSpacing.sm,
              KlinikaSpacing.sm,
              KlinikaSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.textController,
                    builder: (context, value, _) {
                      final hasText = value.text.trim().isNotEmpty;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: hasText
                                ? Text(
                                    'Pret pour le triage',
                                    key: const ValueKey('ready'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: KlinikaPalette.emerald,
                                        ),
                                  )
                                : Text(
                                    'Patient intake',
                                    key: const ValueKey('idle'),
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                          ),
                          TextField(
                            focusNode: _focusNode,
                            controller: controller.textController,
                            maxLines: 5,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(
                              color: KlinikaPalette.snowWhite,
                              fontSize: 15,
                            ),
                            decoration: const InputDecoration(
                              hintText: KlinikaStrings.inputHint,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.only(top: 2),
                            ),
                            onTap: () => HapticFeedback.selectionClick(),
                            onSubmitted: (_) => _submit(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Gap(KlinikaSpacing.sm),
                Obx(
                  () => AnimatedSwitcher(
                    duration: 220.ms,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 48,
                            height: 48,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: KlinikaPalette.emerald,
                                ),
                              ),
                            ),
                          )
                        : _SendButton(onPressed: _submit),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KlinikaPalette.emerald,
      shape: KlinikaShapes.lg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: const SizedBox(
          key: ValueKey('send'),
          width: 50,
          height: 50,
          child: Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedSent,
              color: KlinikaPalette.ink,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
