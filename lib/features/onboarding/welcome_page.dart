import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sielto/core/theme/sage_tokens.dart';

/// The first screen of a fresh install.
///
/// Nothing has happened yet — no account, no network call, no data — so the
/// screen carries the name and one way in. "Sign in on this device" belongs
/// with device linking in M9 and is absent until it works.
class WelcomePage extends StatelessWidget {
  const WelcomePage({required this.onStart, super.key});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: sage.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SageSpace.xl),
          child: Column(
            children: <Widget>[
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sage.accentTintAlt,
                  shape: BoxShape.circle,
                  border: Border.all(color: sage.accent, width: 1.5),
                ),
                child: Text(
                  // The monogram is the product name's initial, not copy: it
                  // stays Latin in every locale, as the name does.
                  'S',
                  style: text.displaySmall?.copyWith(
                    color: sage.accentStrong,
                    fontSize: 40,
                  ),
                ),
              ),
              const SizedBox(height: SageSpace.lg),
              Text(
                'Sielto',
                style: text.displaySmall?.copyWith(
                  fontSize: 30,
                  color: sage.inkHeading,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: SageSpace.sm),
              Text(
                tr('welcome.tagline'),
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(height: 1.6),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onStart,
                  child: Text(tr('welcome.start')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
