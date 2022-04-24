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

/// The LineZone zone defines a zone that contains all the points on a line.
class LineZone implements Zone {
  Point<double> _start;
  Point<double> _end;
  late Point<double> _length;
  late Point<double> _normal;
  late Point<double> _parallel;

  /// The constructor creates a LineZone zone.
  ///
  /// @param start The point at one end of the line.
  /// @param end The point at the other end of the line.
  LineZone(this._start, this._end) {
    setLengthAndNormal();
  }

  void setLengthAndNormal() {
    _length = _end - _start;
    _parallel = Maths.normalizePoint(_length.x, _length.y, 1);
    _normal = Point<double>(_parallel.y, -_parallel.x);
  }

  /// The point at one end of the line.
  Point<double> get start {
    return _start;
  }

  set start(Point<double> value) {
    _start = value;
    setLengthAndNormal();
  }

  /// The point at the other end of the line.
  Point<double> get end {
    return _end;
  }

  set end(Point<double> value) {
    _end = value;
    setLengthAndNormal();
  }

  bool contains(double x, double y) {
    // not on line if dot product with perpendicular is not zero
    if ((x - _start.x) * _length.y - (y - _start.y) * _length.x != 0) {
      return false;
    }
    // is it between the points, dot product of the vectors towards each point is negative
    return (x - _start.x) * (x - _end.x) + (y - _start.y) * (y - _end.y) <= 0;
  }

  Point<double> getLocation() {
    double scale = Random().nextDouble();
    return Point(_length.x * scale, _length.y * scale) + _start;
  }

  /// @inheritDoc
  double getArea() {
    // treat as one pixel tall rectangle
    return _start.distanceTo(_end);
  }

  /// Manages collisions between a particle and the zone. The particle will collide with the line defined
  /// for this zone. In the interests of speed, the collisions are not exactly accurate at the ends of the
  /// line, but are accurate enough to ensure the particle doesn't pass through the line and to look
  /// realistic in most circumstances. The collisionRadius of the particle is used when calculating the collision.
  ///
  /// @param particle The particle to be tested for collision with the zone.
  /// @param bounce The coefficient of restitution for the collision.
  ///
  /// @return Whether a collision occured.
  bool collideParticle(Particle particle, [double bounce = 1]) {
    // if it was moving away from the line, return false
    double previousDistance = (particle.previousX - _start.x) * _normal.x +
        (particle.previousY - _start.y) * _normal.y;
    double velDistance = particle.velX * _normal.x + particle.velY * _normal.y;
    if (previousDistance * velDistance >= 0) {
      return false;
    }

    // if it is further away than the collision radius and the same side as previously, return false
    double distance = (particle.x - _start.x) * _normal.x +
        (particle.y - _start.y) * _normal.y;
    if (distance * previousDistance > 0 &&
        (distance > particle.collisionRadius ||
            distance < -particle.collisionRadius)) {
      return false;
    }

    // move line collisionradius distance in direction particle was, extend it by collision radius
    double offsetX;
    double offsetY;
    if (previousDistance < 0) {
      offsetX = _normal.x * particle.collisionRadius;
      offsetY = _normal.y * particle.collisionRadius;
    } else {
      offsetX = -_normal.x * particle.collisionRadius;
      offsetY = -_normal.y * particle.collisionRadius;
    }
    double thenX = particle.previousX + offsetX;
    double thenY = particle.previousY + offsetY;
    double nowX = particle.x + offsetX;
    double nowY = particle.y + offsetY;
    double startX = _start.x - _parallel.x * particle.collisionRadius;
    double startY = _start.y - _parallel.y * particle.collisionRadius;
    double endX = _end.x + _parallel.x * particle.collisionRadius;
    double endY = _end.y + _parallel.y * particle.collisionRadius;

    double den = 1 /
        ((nowY - thenY) * (endX - startX) - (nowX - thenX) * (endY - startY));

    double u = den *
        ((nowX - thenX) * (startY - thenY) - (nowY - thenY) * (startX - thenX));
    if (u < 0 || u > 1) {
      return false;
    }

    double v = -den *
        ((endX - startX) * (thenY - startY) -
            (endY - startY) * (thenX - startX));
    if (v < 0 || v > 1) {
      return false;
    }

    particle.x = particle.previousX + v * (particle.x - particle.previousX);
    particle.y = particle.previousY + v * (particle.y - particle.previousY);

    double normalSpeed = _normal.x * particle.velX + _normal.y * particle.velY;
    double factor = (1 + bounce) * normalSpeed;
    particle.velX -= factor * _normal.x;
    particle.velY -= factor * _normal.y;
    return true;
  }
}
