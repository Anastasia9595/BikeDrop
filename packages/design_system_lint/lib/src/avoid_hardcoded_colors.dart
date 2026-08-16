import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags direct `Color(...)` construction and `Colors.*` usage outside of
/// `lib/design_system/tokens/app_colors.dart`, where the design system's color
/// tokens are defined. Everywhere else should reference `AppColors` instead
/// of hardcoding colors.
class AvoidHardcodedColors extends DartLintRule {
  const AvoidHardcodedColors() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_hardcoded_colors',
    problemMessage:
        'Do not construct Color(...) or use Colors.* outside app_colors.dart. Use AppColors instead.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  /// True for the one file allowed to define raw colors: the design
  /// system's own `app_colors.dart`. Path separators are normalized so this
  /// works identically on Windows (`\`) and POSIX (`/`) paths.
  bool _isAllowedFile(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.endsWith('lib/design_system/tokens/app_colors.dart');
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (_isAllowedFile(resolver.path)) return;

    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.staticType?.getDisplayString(
        withNullability: false,
      );
      if (typeName == 'Color') {
        reporter.reportErrorForNode(_code, node);
      }
    });

    context.registry.addPrefixedIdentifier((node) {
      if (node.prefix.name == 'Colors') {
        reporter.reportErrorForNode(_code, node);
      }
    });
  }
}
