# Archivo font files

Download Archivo (weights 400/500/600/700/800) from Google Fonts and place the
`.ttf` files here with these exact names:

- Archivo-Regular.ttf (400)
- Archivo-Medium.ttf (500)
- Archivo-SemiBold.ttf (600)
- Archivo-Bold.ttf (700)
- Archivo-ExtraBold.ttf (800)

## Adding the font registration to pubspec.yaml

Once the real `.ttf` files are placed in this directory, add this block to
`pubspec.yaml` under the `flutter:` section:

```yaml
  fonts:
    - family: Archivo
      fonts:
        - asset: assets/fonts/Archivo-Regular.ttf
          weight: 400
        - asset: assets/fonts/Archivo-Medium.ttf
          weight: 500
        - asset: assets/fonts/Archivo-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Archivo-Bold.ttf
          weight: 700
        - asset: assets/fonts/Archivo-ExtraBold.ttf
          weight: 800
```

Without this block and the font files, the app falls back to the platform default
font but still builds and runs normally. The TextStyle definitions in
`lib/design_system/app_typography.dart` reference the `Archivo` font family,
which silently degrades to the platform default when not registered.
