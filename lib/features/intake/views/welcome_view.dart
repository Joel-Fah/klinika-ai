import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme.dart';
import '../../../core/constants/strings.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  static const _seenOnboardingKey = 'klinika_seen_onboarding';

  final _pageController = PageController();
  int _page = 0;
  bool _checkingPreference = true;

  @override
  void initState() {
    super.initState();
    _redirectIfSeen();
  }

  Future<void> _redirectIfSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(_seenOnboardingKey) ?? false;
    if (!mounted) return;

    if (hasSeenOnboarding) {
      context.goNamed('session');
      return;
    }

    setState(() => _checkingPreference = false);
  }

  Future<void> _startSession() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenOnboardingKey, true);
    if (!mounted) return;
    context.goNamed('session');
  }

  void _nextPage() {
    HapticFeedback.selectionClick();
    if (_page == _onboardingCards.length - 1) {
      _startSession();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPreference) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: KlinikaPalette.emerald),
        ),
      );
    }

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final carouselHeight = math.min(
              390.0,
              math.max(290.0, constraints.maxHeight * 0.42),
            );

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                KlinikaSpacing.lg,
                KlinikaSpacing.lg,
                KlinikaSpacing.lg,
                KlinikaSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: ShapeDecoration(
                            color: KlinikaPalette.emeraldSurface,
                            shape: KlinikaShapes.md.copyWith(
                              side: const BorderSide(
                                color: KlinikaPalette.inkBorder,
                              ),
                            ),
                          ),
                          child: const SizedBox(
                            width: 56,
                            height: 56,
                            child: Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedHospital02,
                                color: KlinikaPalette.emerald,
                                size: 28,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms).scale(
                              begin: const Offset(0.86, 0.86),
                            ),
                        const Gap(KlinikaSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                KlinikaStrings.appName,
                                style: textTheme.headlineSmall,
                              ),
                              Text(
                                'GenUI intake for real patient stories',
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(KlinikaSpacing.xl),
                    Text(
                      'Une fiche qui ecoute avant de demander.',
                      style: textTheme.displayMedium,
                    )
                        .animate(delay: 80.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.16),
                    const Gap(KlinikaSpacing.md),
                    Text(
                      'Decrivez ce qui se passe. Gemini construit une interface de triage adaptee, sans vous noyer dans un long formulaire.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: KlinikaPalette.mist,
                      ),
                    )
                        .animate(delay: 160.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.16),
                    const Gap(KlinikaSpacing.lg),
                    SizedBox(
                      height: carouselHeight,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (value) {
                          HapticFeedback.selectionClick();
                          setState(() => _page = value);
                        },
                        itemCount: _onboardingCards.length,
                        itemBuilder: (context, index) {
                          final card = _onboardingCards[index];
                          return _OnboardingPanel(card: card);
                        },
                      ),
                    ),
                    const Gap(KlinikaSpacing.md),
                    Row(
                      children: [
                        ...List.generate(_onboardingCards.length, (index) {
                          final selected = index == _page;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                            width: selected ? 28 : 8,
                            height: 8,
                            margin: const EdgeInsets.only(
                              right: KlinikaSpacing.xs,
                            ),
                            decoration: ShapeDecoration(
                              color: selected
                                  ? KlinikaPalette.emerald
                                  : KlinikaPalette.inkBorder,
                              shape: const StadiumBorder(),
                            ),
                          );
                        }),
                        const Spacer(),
                        TextButton(
                          onPressed: _startSession,
                          child: const Text('Passer'),
                        ),
                        const Gap(KlinikaSpacing.sm),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                          ),
                          onPressed: _nextPage,
                          icon: HugeIcon(
                            icon: _page == _onboardingCards.length - 1
                                ? HugeIcons.strokeRoundedStethoscope02
                                : HugeIcons.strokeRoundedArrowRight01,
                            color: KlinikaPalette.ink,
                            size: 18,
                          ),
                          label: Text(
                            _page == _onboardingCards.length - 1
                                ? KlinikaStrings.startSession
                                : 'Suivant',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static const _onboardingCards = [
    _OnboardingCardData(
      icon: HugeIcons.strokeRoundedLanguageSkill,
      title: 'Parlez naturellement',
      body:
          'Francais, English, Camfranglais: le flux garde le ton du patient et clarifie seulement ce qui manque.',
      chips: ['Francais', 'English', 'Camfranglais'],
    ),
    _OnboardingCardData(
      icon: HugeIcons.strokeRoundedAiNetwork,
      title: 'L interface se construit en direct',
      body:
          'Chaque reponse peut afficher un triage, un service recommande, des symptomes associes et un mini-formulaire utile.',
      chips: ['Triage', 'Service', 'Formulaire'],
    ),
    _OnboardingCardData(
      icon: HugeIcons.strokeRoundedShieldUser,
      title: 'Moins de bruit, plus de soin',
      body:
          'Un enfant avec rash et un adulte avec douleur thoracique ne voient pas la meme fiche. C est tout le point.',
      chips: ['Adapte', 'Rapide', 'Humain'],
    ),
  ];
}

class _OnboardingCardData {
  const _OnboardingCardData({
    required this.icon,
    required this.title,
    required this.body,
    required this.chips,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<String> chips;
}

class _OnboardingPanel extends StatelessWidget {
  const _OnboardingPanel({required this.card});

  final _OnboardingCardData card;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KlinikaSpacing.sm),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: KlinikaPalette.inkLight,
          shape: KlinikaShapes.xl.copyWith(
            side: const BorderSide(color: KlinikaPalette.inkBorder),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(KlinikaSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: KlinikaPalette.emeraldSurface,
                  shape: KlinikaShapes.lg,
                ),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Center(
                    child: HugeIcon(
                      icon: card.icon,
                      color: KlinikaPalette.emerald,
                      size: 34,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.title, style: textTheme.headlineLarge),
                  const Gap(KlinikaSpacing.sm),
                  Text(
                    card.body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: KlinikaPalette.mist,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: KlinikaSpacing.sm,
                runSpacing: KlinikaSpacing.sm,
                children: card.chips
                    .map(
                      (chip) => Chip(
                        label: Text(chip),
                        backgroundColor: KlinikaPalette.inkMid,
                        side: const BorderSide(
                          color: KlinikaPalette.inkBorder,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
