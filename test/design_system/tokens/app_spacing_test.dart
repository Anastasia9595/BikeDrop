import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/tokens/app_spacing.dart';

void main() {
  test('spacing tokens match design doc values', () {
    expect(AppSpacing.screenPaddingH, 20.0);
    expect(AppSpacing.cardRadius, 14.0);
    expect(AppSpacing.buttonRadius, 14.0);
    expect(AppSpacing.dialogRadius, 22.0);
    expect(AppSpacing.photoTileRadius, 6.0);
    expect(AppSpacing.fieldHeight, 56.0);
    expect(AppSpacing.fieldBorderWidth, 1.5);
    expect(AppSpacing.primaryButtonHeight, 60.0);
    expect(AppSpacing.minTapTarget, 44.0);
    expect(AppSpacing.switchTrackWidth, 58.0);
    expect(AppSpacing.switchTrackHeight, 34.0);
    expect(AppSpacing.switchThumbSize, 28.0);
    expect(AppSpacing.listRowPaddingV, 12.0);
    expect(AppSpacing.listRowGap, 12.0);
    expect(AppSpacing.listRowMinHeight, 48.0);
    expect(AppSpacing.snackbarBottomOffset, 136.0);
    expect(AppSpacing.dividerWeight, 2.0);
    expect(AppSpacing.iconSize, 20.0);
    expect(AppSpacing.iconSizeLarge, 48.0);
    expect(AppSpacing.listThumbnailSize, 40.0);
  });
}
