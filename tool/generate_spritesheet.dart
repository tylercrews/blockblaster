import 'package:image/image.dart' as img;
import 'dart:io';

void main() {
  // Create a 400x200 image for the spritesheet (2x2 grid)
  final image = img.Image(
    width: 400,
    height: 200,
    numChannels: 4,
  );

  // Fill with transparent background
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

  // Colors
  final blackLine = img.ColorRgba8(0, 0, 0, 255);
  final yellow = img.ColorRgba8(255, 255, 0, 255);
  final gray = img.ColorRgba8(128, 128, 128, 255);
  // final white = img.ColorRgba8(255, 255, 255, 255);

  // ========== SPRITE 1: Left Ship Half (Top-Left) ==========
  _drawLeftShip(image, 10, 10, blackLine);

  // ========== SPRITE 2: Right Ship Half (Top-Right) ==========
  _drawRightShip(image, 210, 10, blackLine);

  // ========== SPRITE 3: Shot/Bullet (Bottom-Left) ==========
  _drawShot(image, 100, 120, yellow);

  // ========== SPRITE 4: Block (Bottom-Right) ==========
  _drawBlock(image, 210, 110, gray, blackLine);

  // Save the spritesheet
  final output = File('assets/spritesheet.png');
  output.parent.createSync(recursive: true);
  output.writeAsBytesSync(img.encodePng(image));

  print('Spritesheet generated: assets/spritesheet.png');
}

void _drawLeftShip(img.Image image, int offsetX, int offsetY, img.ColorRgba8 color) {
  // Outer rectangle (180x100)
  _drawRect(image, offsetX, offsetY, 180, 100, color);

  // Inner rectangle (140x60, offset)
  _drawRect(image, offsetX + 20, offsetY + 20, 140, 60, color);

  // Left arrow pointing right
  final baseX = offsetX + 50;
  final baseY = offsetY + 50;

  // Horizontal line
  _drawLine(image, baseX, baseY, baseX + 60, baseY, color);

  // Arrow point (top)
  _drawLine(image, baseX + 60, baseY, baseX + 40, baseY - 15, color);

  // Arrow point (bottom)
  _drawLine(image, baseX + 60, baseY, baseX + 40, baseY + 15, color);
}

void _drawRightShip(img.Image image, int offsetX, int offsetY, img.ColorRgba8 color) {
  // Outer rectangle (180x100)
  _drawRect(image, offsetX, offsetY, 180, 100, color);

  // Inner rectangle (140x60, offset from right)
  _drawRect(image, offsetX + 20, offsetY + 20, 140, 60, color);

  // Right arrow pointing left
  final baseX = offsetX + 130;
  final baseY = offsetY + 50;

  // Horizontal line
  _drawLine(image, baseX, baseY, baseX - 60, baseY, color);

  // Arrow point (top)
  _drawLine(image, baseX - 60, baseY, baseX - 40, baseY - 15, color);

  // Arrow point (bottom)
  _drawLine(image, baseX - 60, baseY, baseX - 40, baseY + 15, color);
}

void _drawShot(img.Image image, int centerX, int centerY, img.ColorRgba8 color) {
  const radius = 10;
  _drawFilledCircle(image, centerX, centerY, radius, color);
}

void _drawBlock(img.Image image, int offsetX, int offsetY, img.ColorRgba8 fillColor,
    img.ColorRgba8 outlineColor) {
  const size = 100;
  
  // Fill
  _drawFilledRect(image, offsetX, offsetY, size, size, fillColor);

  // Outline
  _drawRect(image, offsetX, offsetY, size, size, outlineColor);

  // Inner border for 3D effect
  _drawRect(image, offsetX + 10, offsetY + 10, size - 20, size - 20, outlineColor);
}

void _drawRect(img.Image image, int x, int y, int width, int height, img.ColorRgba8 color) {
  // Top line
  _drawLine(image, x, y, x + width, y, color);
  // Bottom line
  _drawLine(image, x, y + height, x + width, y + height, color);
  // Left line
  _drawLine(image, x, y, x, y + height, color);
  // Right line
  _drawLine(image, x + width, y, x + width, y + height, color);
}

void _drawFilledRect(img.Image image, int x, int y, int width, int height,
    img.ColorRgba8 color) {
  for (int py = y; py < y + height; py++) {
    for (int px = x; px < x + width; px++) {
      if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
        image.setPixelRgba(px, py, color.r, color.g, color.b, color.a);
      }
    }
  }
}

void _drawLine(img.Image image, int x1, int y1, int x2, int y2,
    img.ColorRgba8 color) {
  // Bresenham's line algorithm
  int dx = (x2 - x1).abs();
  int dy = (y2 - y1).abs();
  int sx = x1 < x2 ? 1 : -1;
  int sy = y1 < y2 ? 1 : -1;
  int err = dx - dy;

  int x = x1;
  int y = y1;

  while (true) {
    if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
      image.setPixelRgba(x, y, color.r, color.g, color.b, color.a);
    }

    if (x == x2 && y == y2) break;

    int e2 = 2 * err;
    if (e2 > -dy) {
      err -= dy;
      x += sx;
    }
    if (e2 < dx) {
      err += dx;
      y += sy;
    }
  }
}

void _drawFilledCircle(img.Image image, int centerX, int centerY, int radius,
    img.ColorRgba8 color) {
  for (int y = centerY - radius; y <= centerY + radius; y++) {
    for (int x = centerX - radius; x <= centerX + radius; x++) {
      int dx = x - centerX;
      int dy = y - centerY;
      if (dx * dx + dy * dy <= radius * radius) {
        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          image.setPixelRgba(x, y, color.r, color.g, color.b, color.a);
        }
      }
    }
  }
}
