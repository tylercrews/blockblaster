import 'package:flutter/material.dart';

/// Color palette derived from the CMYK color wheel.
///
/// Hues follow the wheel clockwise: Red → Vermillion → Orange → Amber →
/// Yellow → Chartreuse → Green → Spring Green → Cyan → Sky Blue → Blue →
/// Indigo → Violet → Magenta → Pink.
///
/// Each [ColorFamily] contains 10 shades ordered lightest → darkest (index 0–9).
/// Index 5 is the pure saturated hue. Shades 0–4 mix toward white;
/// shades 6–9 mix toward black.
/// [ColorFamily.preview] returns index 5 for use as a compact family chip.
///
/// [grayscale] provides 10 steps from white (index 0) to black (index 9).

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class ColorFamily {
  final String name;

  /// 10 shades: 0 = pastel (near white) … 5 = pure hue … 9 = deep (near black).
  final List<Color> shades;

  const ColorFamily({required this.name, required this.shades});

  /// Representative swatch for family preview chips (pure hue).
  Color get preview => shades[5];

  /// Convenience accessors.
  Color get pastel    => shades[0];
  Color get veryLight => shades[1];
  Color get light     => shades[2];
  Color get medium    => shades[5]; // pure hue
  Color get dark      => shades[7];
  Color get veryDark  => shades[8];
  Color get deep      => shades[9];
}

// ---------------------------------------------------------------------------
// Color families  (10 shades each: 0–4 lighten toward white, 5 = pure hue,
//                  6–9 darken toward black)
// ---------------------------------------------------------------------------

const List<ColorFamily> colorFamilies = [
  // --- Reds / Warm -----------------------------------------------------------
  ColorFamily(
    name: 'Red',
    shades: [
      Color(0xFFFFE6E6), // 0 pastel
      Color(0xFFFFCCCC), // 1 very light
      Color(0xFFFFA6A6), // 2 light
      Color(0xFFFF8080), // 3 light-medium
      Color(0xFFFF4D4D), // 4 medium-light
      Color(0xFFFF0000), // 5 pure ← preview
      Color(0xFFD90000), // 6 medium-dark
      Color(0xFFA60000), // 7 dark
      Color(0xFF730000), // 8 very dark
      Color(0xFF400000), // 9 deep
    ],
  ),
  ColorFamily(
    name: 'Vermillion',
    shades: [
      Color(0xFFFFEEE6),
      Color(0xFFFFDECE),
      Color(0xFFFFC5A6),
      Color(0xFFFFAC80),
      Color(0xFFFF8B4D),
      Color(0xFFFF5900), // pure
      Color(0xFFD94C00),
      Color(0xFFA63A00),
      Color(0xFF732800),
      Color(0xFF401600),
    ],
  ),
  ColorFamily(
    name: 'Orange',
    shades: [
      Color(0xFFFFF5E6),
      Color(0xFFFFEBCC),
      Color(0xFFFFDBA6),
      Color(0xFFFFCC80),
      Color(0xFFFFB84D),
      Color(0xFFFF9900), // pure
      Color(0xFFD98200),
      Color(0xFFA66300),
      Color(0xFF734500),
      Color(0xFF402600),
    ],
  ),
  ColorFamily(
    name: 'Amber',
    shades: [
      Color(0xFFFFFAE6),
      Color(0xFFFFF5CC),
      Color(0xFFFFEDA6),
      Color(0xFFFFE680),
      Color(0xFFFFDB4D),
      Color(0xFFFFCC00), // pure
      Color(0xFFD9AD00),
      Color(0xFFA68500),
      Color(0xFF735C00),
      Color(0xFF403300),
    ],
  ),

  // --- Yellows / Greens ------------------------------------------------------
  ColorFamily(
    name: 'Yellow',
    shades: [
      Color(0xFFFFFFE6),
      Color(0xFFFFFFCC),
      Color(0xFFFFFFA6),
      Color(0xFFFFFF80),
      Color(0xFFFFFF4D),
      Color(0xFFFFFF00), // pure
      Color(0xFFD9D900),
      Color(0xFFA6A600),
      Color(0xFF737300),
      Color(0xFF404000),
    ],
  ),
  ColorFamily(
    name: 'Chartreuse',
    shades: [
      Color(0xFFF9FFE6),
      Color(0xFFF2FFCC),
      Color(0xFFE9FFA6),
      Color(0xFFDFFF80),
      Color(0xFFD2FF4D),
      Color(0xFFBFFF00), // pure
      Color(0xFFA2D900),
      Color(0xFF7CA600),
      Color(0xFF567300),
      Color(0xFF304000),
    ],
  ),
  ColorFamily(
    name: 'Green',
    shades: [
      Color(0xFFE6FFE6),
      Color(0xFFCCFFCC),
      Color(0xFFA6FFA6),
      Color(0xFF80FF80),
      Color(0xFF4DFF4D),
      Color(0xFF00FF00), // pure
      Color(0xFF00D900),
      Color(0xFF00A600),
      Color(0xFF007300),
      Color(0xFF004000),
    ],
  ),
  ColorFamily(
    name: 'Spring Green',
    shades: [
      Color(0xFFE6FFF2),
      Color(0xFFCCFFE6),
      Color(0xFFA6FFD3),
      Color(0xFF80FFC0),
      Color(0xFF4DFFA6),
      Color(0xFF00FF80), // pure
      Color(0xFF00D96D),
      Color(0xFF00A653),
      Color(0xFF00733A),
      Color(0xFF004020),
    ],
  ),

  // --- Blues / Cyans ---------------------------------------------------------
  ColorFamily(
    name: 'Cyan',
    shades: [
      Color(0xFFE6FFFF),
      Color(0xFFCCFFFF),
      Color(0xFFA6FFFF),
      Color(0xFF80FFFF),
      Color(0xFF4DFFFF),
      Color(0xFF00FFFF), // pure
      Color(0xFF00D9D9),
      Color(0xFF00A6A6),
      Color(0xFF007373),
      Color(0xFF004040),
    ],
  ),
  ColorFamily(
    name: 'Sky Blue',
    shades: [
      Color(0xFFE6F5FF),
      Color(0xFFCCEBFF),
      Color(0xFFA6DBFF),
      Color(0xFF80CCFF),
      Color(0xFF4DB8FF),
      Color(0xFF0099FF), // pure
      Color(0xFF0082D9),
      Color(0xFF0063A6),
      Color(0xFF004573),
      Color(0xFF002640),
    ],
  ),
  ColorFamily(
    name: 'Blue',
    shades: [
      Color(0xFFE6F0FF),
      Color(0xFFCCE0FF),
      Color(0xFFA6C9FF),
      Color(0xFF80B3FF),
      Color(0xFF4D94FF),
      Color(0xFF0066FF), // pure
      Color(0xFF0057D9),
      Color(0xFF0042A6),
      Color(0xFF002E73),
      Color(0xFF001A40),
    ],
  ),
  ColorFamily(
    name: 'Indigo',
    shades: [
      Color(0xFFEBE6FF),
      Color(0xFFD6CCFF),
      Color(0xFFB8A6FF),
      Color(0xFF9980FF),
      Color(0xFF704DFF),
      Color(0xFF3300FF), // pure
      Color(0xFF2B00D9),
      Color(0xFF2100A6),
      Color(0xFF170073),
      Color(0xFF0D0040),
    ],
  ),

  // --- Purples / Pinks -------------------------------------------------------
  ColorFamily(
    name: 'Violet',
    shades: [
      Color(0xFFF5E6FF),
      Color(0xFFEBCCFF),
      Color(0xFFDBA6FF),
      Color(0xFFCC80FF),
      Color(0xFFB84DFF),
      Color(0xFF9900FF), // pure
      Color(0xFF8200D9),
      Color(0xFF6300A6),
      Color(0xFF450073),
      Color(0xFF260040),
    ],
  ),
  ColorFamily(
    name: 'Magenta',
    shades: [
      Color(0xFFFFE6FF),
      Color(0xFFFFCCFF),
      Color(0xFFFFA6FF),
      Color(0xFFFF80FF),
      Color(0xFFFF4DFF),
      Color(0xFFFF00FF), // pure
      Color(0xFFD900D9),
      Color(0xFFA600A6),
      Color(0xFF730073),
      Color(0xFF400040),
    ],
  ),
  ColorFamily(
    name: 'Pink',
    shades: [
      Color(0xFFFFE6FA),
      Color(0xFFFFCCF5),
      Color(0xFFFFA6ED),
      Color(0xFFFF80E6),
      Color(0xFFFF4DDB),
      Color(0xFFFF00CC), // pure
      Color(0xFFD900AD),
      Color(0xFFA60085),
      Color(0xFF73005C),
      Color(0xFF400033),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Grayscale  (10 steps, index 0 = white, index 9 = black)
// ---------------------------------------------------------------------------

const List<Color> grayscale = [
  Color(0xFFFFFFFF), // White
  Color(0xFFE6E6E6),
  Color(0xFFCCCCCC),
  Color(0xFFB3B3B3),
  Color(0xFF999999),
  Color(0xFF808080),
  Color(0xFF666666),
  Color(0xFF4D4D4D),
  Color(0xFF333333),
  Color(0xFF000000), // Black
];

// ---------------------------------------------------------------------------
// Convenience helpers
// ---------------------------------------------------------------------------

/// All selectable colors as a flat list: every shade of every family,
/// followed by grayscale.  Useful for simple grid-style pickers.
List<Color> get allColors => [
      for (final family in colorFamilies) ...family.shades,
      ...grayscale,
    ];

/// Look up a [ColorFamily] by name (case-sensitive).
ColorFamily? colorFamilyByName(String name) {
  try {
    return colorFamilies.firstWhere((f) => f.name == name);
  } catch (_) {
    return null;
  }
}

const List<int> health = [0, 1, 2, 4, 8, 16, 32, 64, 128, 256, 512];

/// Default color palette for quick-pick selectors.
/// Index 0 is null (no color / transparent); remaining entries are
/// the pure-hue (index 5) of their respective [ColorFamily].
const List<Color?> defaultColors = [
  null,                // 0  none / transparent
  Color(0xFFFFFFFF),   // 1  white
  Color(0xFFFF0000),   // 2  red
  Color(0xFFFF9900),   // 3  orange
  Color(0xFFFFFF00),   // 4  yellow
  Color(0xFF00FF00),   // 5  green
  Color(0xFF0066FF),   // 6  blue
  Color(0xFFFF00FF),   // 7  magenta
  Color(0xFF00FF80),   // 8  spring green
  Color(0xFF00FFFF),   // 9  cyan
  Color(0xFF000000),   // 10 black
];