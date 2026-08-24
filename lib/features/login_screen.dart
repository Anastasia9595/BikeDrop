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
                Row(
                  children: [
                    Text('BikeDrop', style: AppTypography.loginWordmark),
                    const SizedBox(width: 32),
                    Image.asset('assets/images/bicycle.png', height: 42),
                  ],
                ),

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
                  maxLines: 1,
                  onChanged: (value) {
                    // Handle email input change
                  },
                ),
                const SizedBox(height: AppSpacing.fieldGap),
                AppTextField(
                  label: l10n.loginPasswordLabel,
                  obscureText: true,
                  suffixIcon: Icon(Icons.visibility),
                  onChanged: (value) {
                    // Handle password input change
                  },
                ),
                const SizedBox(height: 42),
                AppPrimaryButton(
                  label: l10n.loginButtonLabel,
                  icon: Icons.arrow_forward,
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
