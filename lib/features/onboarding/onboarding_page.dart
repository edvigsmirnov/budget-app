import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/core/settings/settings_providers.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/features/spaces/space_form_page.dart';

/// First run (spec 2.1): a nickname, then the first Space.
///
/// No account, no email, no network call — the user id was generated locally
/// before this screen was built. The app-lock step of the spec belongs to M7
/// and is absent rather than promised.
///
/// The spec's separate currency step is folded into the Space form: currency
/// is a property of a Space, and asking twice would make the first answer look
/// like a global setting it is not.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _controller = PageController();

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
    return Scaffold(
      backgroundColor: context.sage.surface,
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          _NicknameStep(onContinue: _next),
          const SpaceFormPage(isFirstSpace: true),
        ],
      ),
    );
  }
}

class _NicknameStep extends ConsumerStatefulWidget {
  const _NicknameStep({required this.onContinue});

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
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(SageSpace.formGutter),
        children: <Widget>[
          const SizedBox(height: SageSpace.xl),
          Text(tr('onboarding.welcomeTitle'), style: text.titleLarge),
          const SizedBox(height: SageSpace.sm),
          Text(tr('onboarding.welcomeBody'), style: text.bodyMedium),
          const SizedBox(height: SageSpace.xl),
          LabelledField(
            label: tr('onboarding.fieldNickname'),
            child: TextField(
              controller: _nickname,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: tr('onboarding.nicknameHint'),
              ),
              onSubmitted: (String _) => _save(),
            ),
          ),
          const SizedBox(height: SageSpace.xs),
          Text(tr('onboarding.nicknameWhy'), style: text.bodySmall),
          const SizedBox(height: SageSpace.xl),
          FilledButton(onPressed: _save, child: Text(tr('common.continue'))),
        ],
      ),
    );
  }
}
