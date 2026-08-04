import 'package:flutter/material.dart';
import 'package:bikedrop/design_system/design_system.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('BikeDrop', style: AppTypography.loginWordmark),
                const SizedBox(height: 16),
                Text(
                  'Willkommen zurück!',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                AppPrimaryButton(
                  label: 'Login',
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