import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/core/format/currencies.dart';
import 'package:sielto/core/settings/settings_providers.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/features/onboarding/onboarding_scaffold.dart';
import 'package:sielto/features/onboarding/welcome_page.dart';
import 'package:sielto/features/spaces/space_form_page.dart';

/// First run (spec 2.1): a nickname, a currency, then the first Space.
///
/// No account, no email, no network call — the user id was generated locally
/// before this screen was built. App lock and the Recovery Key are steps 3 and
/// 4 of the spec's flow; they arrive with M7, and the progress bar counts the
/// steps that exist rather than pretending they are already there.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _controller = PageController();

  /// Nickname, currency, Space. The Space form is the last one.
  static const int _stepCount = 3;

  bool _started = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() => _controller.nextPage(
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return WelcomePage(onStart: () => setState(() => _started = true));
    }

    return Scaffold(
      backgroundColor: context.sage.surface,
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          _NicknameStep(stepCount: _stepCount, onContinue: _next),
          _CurrencyStep(stepCount: _stepCount, onContinue: _next),
          const SpaceFormPage(
            isFirstSpace: true,
            step: _stepCount,
            stepCount: _stepCount,
          ),
        ],
      ),
    );
  }
}

class _NicknameStep extends ConsumerStatefulWidget {
  const _NicknameStep({required this.stepCount, required this.onContinue});

  final int stepCount;
  final VoidCallback onContinue;

  @override
  ConsumerState<_NicknameStep> createState() => _NicknameStepState();
}

class _NicknameStepState extends ConsumerState<_NicknameStep> {
  final TextEditingController _nickname = TextEditingController();

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(localSettingsProvider).setNickname(_nickname.text);
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) => OnboardingScaffold(
    step: 1,
    stepCount: widget.stepCount,
    title: tr('onboarding.nicknameTitle'),
    body: tr('onboarding.nicknameWhy'),
    primaryLabel: tr('common.next'),
    onPrimary: _save,
    // Optional, and the spec says so — the step has to be skippable rather
    // than merely ignorable.
    secondaryLabel: tr('common.skip'),
    onSecondary: widget.onContinue,
    children: <Widget>[
      TextField(
        controller: _nickname,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(hintText: tr('onboarding.nicknameHint')),
        onSubmitted: (String _) => _save(),
      ),
    ],
  );
}

/// The currency, asked once here rather than buried in the Space form
/// (spec 2.1, step 2).
///
/// Stored as the device default, so every later Space starts from the same
/// answer instead of asking again.
class _CurrencyStep extends ConsumerStatefulWidget {
  const _CurrencyStep({required this.stepCount, required this.onContinue});

  final int stepCount;
  final VoidCallback onContinue;

  @override
  ConsumerState<_CurrencyStep> createState() => _CurrencyStepState();
}

class _CurrencyStepState extends ConsumerState<_CurrencyStep> {
  String? _chosen;

  @override
  Widget build(BuildContext context) {
    final String locale = context.locale.toString();
    final String currency =
        _chosen ??
        ref.read(localSettingsProvider).currencyCode ??
        Currencies.forLocale(locale);

    return OnboardingScaffold(
      step: 2,
      stepCount: widget.stepCount,
      title: tr('onboarding.currencyTitle'),
      body: tr('onboarding.currencyWhy'),
      primaryLabel: tr('common.next'),
      onPrimary: () async {
        await ref.read(localSettingsProvider).setCurrencyCode(currency);
        widget.onContinue();
      },
      children: <Widget>[
        LabelledField(
          label: tr('space.fieldCurrency'),
          child: DropdownButtonFormField<String>(
            initialValue: currency,
            items: <DropdownMenuItem<String>>[
              for (final String code in Currencies.offered(currency))
                DropdownMenuItem<String>(
                  value: code,
                  child: Text(Currencies.label(code, locale)),
                ),
            ],
            onChanged: (String? code) =>
                setState(() => _chosen = code ?? currency),
          ),
        ),
      ],
    );
  }
}
