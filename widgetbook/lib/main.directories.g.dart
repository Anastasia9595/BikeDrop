// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bikedrop_widgetbook/use_cases/atoms/app_primary_button.dart'
    as _bikedrop_widgetbook_use_cases_atoms_app_primary_button;
import 'package:bikedrop_widgetbook/use_cases/atoms/app_secondary_button.dart'
    as _bikedrop_widgetbook_use_cases_atoms_app_secondary_button;
import 'package:bikedrop_widgetbook/use_cases/atoms/app_text_field.dart'
    as _bikedrop_widgetbook_use_cases_atoms_app_text_field;
import 'package:bikedrop_widgetbook/use_cases/atoms/category_badge.dart'
    as _bikedrop_widgetbook_use_cases_atoms_category_badge;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'design_system',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'atoms',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'AppPrimaryButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _bikedrop_widgetbook_use_cases_atoms_app_primary_button
                    .appPrimaryButtonDefault,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Disabled',
                builder: _bikedrop_widgetbook_use_cases_atoms_app_primary_button
                    .appPrimaryButtonDisabled,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'With icon',
                builder: _bikedrop_widgetbook_use_cases_atoms_app_primary_button
                    .appPrimaryButtonWithIcon,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'AppSecondaryButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _bikedrop_widgetbook_use_cases_atoms_app_secondary_button
                        .appSecondaryButtonDefault,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Disabled',
                builder:
                    _bikedrop_widgetbook_use_cases_atoms_app_secondary_button
                        .appSecondaryButtonDisabled,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'AppTextField',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _bikedrop_widgetbook_use_cases_atoms_app_text_field
                    .appTextFieldDefault,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Error',
                builder: _bikedrop_widgetbook_use_cases_atoms_app_text_field
                    .appTextFieldError,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Obscured',
                builder: _bikedrop_widgetbook_use_cases_atoms_app_text_field
                    .appTextFieldObscured,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CategoryBadge',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _bikedrop_widgetbook_use_cases_atoms_category_badge
                    .categoryBadgeDefault,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
