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
import 'package:bikedrop_widgetbook/use_cases/molecules/app_snackbar.dart'
    as _bikedrop_widgetbook_use_cases_molecules_app_snackbar;
import 'package:bikedrop_widgetbook/use_cases/molecules/list_column_header.dart'
    as _bikedrop_widgetbook_use_cases_molecules_list_column_header;
import 'package:bikedrop_widgetbook/use_cases/organisms/delete_confirmation_dialog.dart'
    as _bikedrop_widgetbook_use_cases_organisms_delete_confirmation_dialog;
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
                name: 'Interactive',
                builder: _bikedrop_widgetbook_use_cases_atoms_app_primary_button
                    .appPrimaryButtonInteractive,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'AppSecondaryButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Interactive',
                builder:
                    _bikedrop_widgetbook_use_cases_atoms_app_secondary_button
                        .appSecondaryButtonInteractive,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'AppTextField',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Interactive',
                builder: _bikedrop_widgetbook_use_cases_atoms_app_text_field
                    .appTextFieldInteractive,
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
      _widgetbook.WidgetbookFolder(
        name: 'molecules',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'AppSnackbar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Interactive',
                builder: _bikedrop_widgetbook_use_cases_molecules_app_snackbar
                    .appSnackbarInteractive,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ListColumnHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _bikedrop_widgetbook_use_cases_molecules_list_column_header
                        .listColumnHeaderDefault,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'organisms',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'DeleteConfirmationDialog',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _bikedrop_widgetbook_use_cases_organisms_delete_confirmation_dialog
                        .deleteConfirmationDialogDefault,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
