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

/// The PathZone zone defines a shaped zone based on a Path.
/// The zone contains the shape of the Path. The Path must be
/// on the stage for it to be used, since it's position on stage determines the
/// position of the zone.

class PathZone implements Zone {
  late Path _path;
  List<Offset> _points = [];

  /// The constructor creates a PathZone object.
  ///
  /// @param path The Path that defines the zone.
  /// @param emitter The renderer that you plan to use the zone with. The
  /// coordinates of the Path are translated to the local coordinate
  /// space of the renderer.
  PathZone(Path path) {
    this.path = path;
  }

  void calculateArea() {
    Rect bounds = _path.getBounds();
    _points.clear();
    double right = bounds.right;
    double bottom = bounds.bottom;
    for (double x = bounds.left; x <= right; ++x) {
      for (double y = bounds.top; y <= bottom; ++y) {
        final pt = Offset(x, y);
        if (_path.contains(pt)) {
          _points.add(pt);
        }
      }
    }
  }

  /// The Path that defines the zone.
  Path get path {
    return _path;
  }

  set path(Path value) {
    _path = value;
    calculateArea();
  }

  /// The contains method determines whether a point is inside the zone.
  ///
  /// @param point The location to test for.
  /// @return true if point is inside the zone, false if it is outside.
  bool contains(double x, double y) {
    return _path.contains(Offset(x, y));
  }

  /// Returns a random point inside the zone.
  Point<double> getLocation() {
    if (_points.length == 0) {
      return Point(0.0, 0.0);
    }

    final idx = Random().nextInt(_points.length);
    final pt = _points[idx];
    return Point(pt.dx, pt.dy);
  }

  /// The getArea method returns the size of the zone.
  /// It's used by the MultiZone class to manage the balancing between the
  /// different zones.
  ///
  /// @return the size of the zone.
  double getArea() => _points.length.toDouble();

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
