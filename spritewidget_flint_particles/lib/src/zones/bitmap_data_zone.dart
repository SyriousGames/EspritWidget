/*
 * FLINT PARTICLE SYSTEM
 * .....................
 * 
 * Author: Richard Lord
 * Copyright (c) Richard Lord 2008-2011
 * http://flintparticles.org
 * 
 * 
 * Licence Agreement
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:  
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

part of flint_particles;

/// The BitmapData zone defines a shaped zone based on an image.
/// The zone contains all pixels in the bitmap that are not transparent -
/// i.e. they have an alpha value greater than zero.
class BitmapDataZone implements Zone {
  late ByteData _bitmapData;
  int imgWidth;
  int imgHeight;
  WeightedList<Point<int>> _validPoints = WeightedList();

  /// A horizontal offset to apply to the pixels in the BitmapData object
  /// to reposition the zone
  double offsetX;

  /// A vertical offset to apply to the pixels in the BitmapData object
  /// to reposition the zone
  double offsetY;

  /// A scale factor to stretch the bitmap horizontally
  double scaleX;

  /// A scale factor to stretch the bitmap vertically
  double scaleY;

  /// The constructor creates a BitmapDataZone object.
  ///
  /// @param bitmapData RGBA pixel data that defines the zone.
  /// @param imgWidth the width of the image in [bitmapData].
  /// @param imgHeight the height of the image in [bitmapData]
  /// @param xOffset A horizontal offset to apply to the pixels in the BitmapData object
  /// to reposition the zone
  /// @param yOffset A vertical offset to apply to the pixels in the BitmapData object
  /// to reposition the zone
  /// @param scaleX A scale factor to stretch the bitmap horizontally
  /// @param scaleY A scale factor to stretch the bitmap vertically
  BitmapDataZone(ByteData bitmapData, this.imgWidth, this.imgHeight,
      [this.offsetX = 0, this.offsetY = 0, this.scaleX = 1, this.scaleY = 1]) {
    _bitmapData = bitmapData;
    _invalidate();
  }

  /// This method forces the zone to reevaluate itself. It should be called whenever the
  /// image object changes. However, it is an intensive method and
  /// calling it frequently will likely slow your code down.
  void _invalidate() {
    _validPoints.clear();
    for (int x = 0; x < imgWidth; ++x) {
      for (int y = 0; y < imgHeight; ++y) {
        final weight = _pixelWeight(x, y);
        if (weight != 0) {
          _validPoints.add(Point(x, y), weight);
        }
      }
    }
  }

  /// This provides a pixel weighting based on the alpha component. A subclass can override to provide a different weighting.
  double _pixelWeight(int x, int y) {
    final pixel = _getPixelRGBA(x, y);
    final alpha = (pixel & 0xFF).toDouble() / 255.0;
    return alpha;
  }

  int _getPixelRGBA(int x, int y) {
    final offset = (y * imgWidth * 4) + (x * 4);
    return _bitmapData.getUint32(offset);
  }

  /// The contains method determines whether a point is inside the zone.
  ///
  /// @param point The location to test for.
  /// @return true if point is inside the zone, false if it is outside.
  bool contains(double x, double y) {
    if (x >= offsetX &&
        x <= offsetX + imgWidth * scaleX &&
        y >= offsetY &&
        y <= offsetY + imgHeight * scaleY) {
      final weight = _pixelWeight(
          ((x - offsetX) / scaleX).round(), ((y - offsetY) / scaleY).round());
      return weight != 0;
    }
    return false;
  }

  /// The getLocation method returns a random point inside the zone.
  ///
  /// @return a random point inside the zone.
  Point<double> getLocation() {
    if (_validPoints.length == 0) {
      return Point(0, 0);
    }

    final p = _validPoints.getRandomValue();
    final x = p.x * scaleX + offsetX;
    final y = p.y * scaleY + offsetY;
    return Point(x, y);
  }

  /// The getArea method returns the size of the zone.
  /// It's used by the MultiZone class to manage the balancing between the
  /// different zones.
  ///
  /// @return the size of the zone.
  double getArea() {
    return (imgWidth * scaleX) * (imgHeight * scaleY);
  }

  /// Manages collisions between a particle and the zone. The particle will collide with the edges of
  /// the zone, from the inside or outside. In the interests of speed, these collisions do not take
  /// account of the collisionRadius of the particle and they do not calculate an accurate bounce
  /// direction from the shape of the zone. Priority is placed on keeping particles inside
  /// or outside the zone.
  ///
  /// @param particle The particle to be tested for collision with the zone.
  /// @param bounce The coefficient of restitution for the collision.
  ///
  /// @return Whether a collision occured.
  bool collideParticle(Particle particle, [double bounce = 1]) {
    if (contains(particle.x, particle.y) !=
        contains(particle.previousX, particle.previousY)) {
      particle.x = particle.previousX;
      particle.y = particle.previousY;
      particle.velX = -bounce * particle.velX;
      particle.velY = -bounce * particle.velY;
      return true;
    } else {
      return false;
    }
  }
}
