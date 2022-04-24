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

/// The Greyscale zone defines a shaped zone based on a BitmapData object.
/// The zone contains all pixels in the bitmap that are not black, with a weighting
/// such that lighter pixels are more likely to be selected than darker pixels
/// when creating particles inside the zone.
class GreyscaleZone extends BitmapDataZone {
  /// The constructor creates a GreyscaleZone object.
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
  GreyscaleZone(ByteData bitmapData, int imgWidth, int imgHeight,
      [double offsetX = 0,
      double offsetY = 0,
      double scaleX = 1,
      double scaleY = 1])
      : super(
            bitmapData, imgWidth, imgHeight, offsetX, offsetY, scaleX, scaleY);

  /// This provides a pixel weighting based on the greyscale of the pixel. Black = 0.
  double _pixelWeight(int x, int y) {
    final pixel = _getPixelRGBA(x, y) >> 8; // Remove alpha
    final grey = (0.11 * (pixel & 0xFF) +
            0.59 * ((pixel >> 8) & 0xFF) +
            0.3 * ((pixel >> 16) & 0xFF)) /
        255.0;
    return grey;
  }
}
