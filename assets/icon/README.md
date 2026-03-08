# App Icon Assets

This directory contains the source images for generating app icons across all platforms.

## Required Images

You need to add the following three PNG images to this directory:

### 1. app_icon.png
- **Size**: 1024x1024px
- **Format**: PNG with transparency
- **Content**: Complete Solar App logo
- **Used for**: Windows, Linux, and legacy Android devices

### 2. app_icon_foreground.png
- **Size**: 1024x1024px
- **Format**: PNG with transparency
- **Content**: Solar App logo centered within a 800x800px safe zone
- **Important**: Leave 112ox margin on all sides for different device shapes (circles, squircles, rounded squares)
- **Used for**: Modern Android adaptive icons (API 26+)

### 3. app_icon_background.png
- **Size**: 1024x1024px
- **Format**: PNG (solid color or gradient)
- **Content**: Background layer only (no logo)
- **Alternative**: You can use a solid color in the configuration instead
- **Used for**: Modern Android adaptive icon background layer

## After Adding Images

Once you've added all three PNG files to this directory, run:

```bash
# Install dependencies
flutter pub get

# Generate icons for all platforms
dart run flutter_launcher_icons
```

This will automatically generate:
- Android icons (5 density variants: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Android adaptive icons (foreground + background layers)
- Windows .ico file
- Linux icon