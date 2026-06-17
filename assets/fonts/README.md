# Fonts — Hanken Grotesk

The app's single typeface (design-system decision: one family, numerics use it with
tabular figures — no Spline Sans Mono). Drop the five static weight files here, named
**exactly** as below, so they match the `pubspec.yaml` `fonts:` declaration (brief
`01-theming-foundation`):

| Weight | FontWeight | Filename (place in this folder) |
|--------|-----------|----------------------------------|
| 400 Regular   | w400 | `HankenGrotesk-Regular.ttf`   |
| 500 Medium    | w500 | `HankenGrotesk-Medium.ttf`    |
| 600 SemiBold  | w600 | `HankenGrotesk-SemiBold.ttf`  |
| 700 Bold      | w700 | `HankenGrotesk-Bold.ttf`      |
| 800 ExtraBold | w800 | `HankenGrotesk-ExtraBold.ttf` |

## Where to get them

Hanken Grotesk is free (SIL Open Font License). Either:

- **Google Fonts:** <https://fonts.google.com/specimen/Hanken+Grotesk> → "Get font" → "Download
  all". Unzip; the static weight files are in the `static/` subfolder. Copy the five files
  above out of `static/` into this folder (the top-level `HankenGrotesk-VariableFont_wght.ttf`
  is not needed for the static-weight setup).
- **GitHub (google/fonts):** <https://github.com/google/fonts/tree/main/ofl/hankengrotesk> —
  OFL source.

If a download only gives you the **variable font** (`...VariableFont_wght.ttf`) and no
`static/` folder, drop that single file here instead and tell Claude — the pubspec can
declare one variable asset across the weight axis rather than five static files.

`pubspec.yaml` (declared by brief 01) will read:

```yaml
  fonts:
    - family: Hanken Grotesk
      fonts:
        - asset: assets/fonts/HankenGrotesk-Regular.ttf
        - asset: assets/fonts/HankenGrotesk-Medium.ttf
          weight: 500
        - asset: assets/fonts/HankenGrotesk-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/HankenGrotesk-Bold.ttf
          weight: 700
        - asset: assets/fonts/HankenGrotesk-ExtraBold.ttf
          weight: 800
```
