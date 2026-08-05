import 'package:flutter/material.dart';
import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BikeDrop', style: AppTypography.loginWordmark),
                const SizedBox(height: 16),
                Text(
                  l10n.loginWelcomeBack,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),
                AppTextField(
                  label: l10n.loginEmailLabel,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    // Handle email input change
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.loginPasswordLabel,
                  obscureText: true,
                  onChanged: (value) {
                    // Handle password input change
                  },
                ),
                const SizedBox(height: 32),
                AppPrimaryButton(
                  label: l10n.loginButtonLabel,
                  onPressed: () {
                    // Handle login action
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
