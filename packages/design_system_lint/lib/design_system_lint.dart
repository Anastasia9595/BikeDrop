import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/avoid_hardcoded_colors.dart';

PluginBase createPlugin() => _DesignSystemLintPlugin();

class _DesignSystemLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [
        AvoidHardcodedColors(),
      ];
}
