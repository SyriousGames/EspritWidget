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

/// The DiscSectorZone zone defines a section of a Disc zone. The disc
/// on which it's based have a hole in the middle, like a doughnut.
class DiscSectorZone implements Zone {
  /// The center of the disc.
  Point<double> center;
  late double _innerRadius;
  late double _outerRadius;
  late double _innerSq;
  late double _outerSq;
  double _minAngle = 0;
  double _maxAngle = 360;
  double _minAllowed = 0;
  late Point<double> _minNormal;
  late Point<double> _maxNormal;

  static const double TWOPI = pi * 2;

  /// The constructor defines a DiscSectorZone zone.
  ///
  /// @param center The center of the disc.
  /// @param outerRadius The radius of the outer edge of the disc.
  /// @param innerRadius If set, this defines the radius of the inner
  /// edge of the disc. Points closer to the center than this inner radius
  /// are excluded from the zone. If this parameter is not set then all
  /// points inside the outer radius are included in the zone.
  /// @param minAngle The minimum angle, in degrees, for points to be included in the zone.
  /// An angle of zero is horizontal and to the right. Positive angles are in a clockwise
  /// direction (towards the graphical y axis). Angles are converted to a value between 0
  /// and 360.
  /// @param maxAngle The maximum angle, in degrees, for points to be included in the zone.
  /// An angle of zero is horizontal and to the right. Positive angles are in a clockwise
  /// direction (towards the graphical y axis). Angles are converted to a value between 0
  /// and 360.
  DiscSectorZone(this.center,
      [double outerRadius = 0,
      double innerRadius = 0,
      double minAngle = 0,
      double maxAngle = 0]) {
    if (outerRadius < innerRadius) {
      throw Exception(
          'The outerRadius ($outerRadius) cannot be smaller than the innerRadius ($innerRadius)');
    }

    this.innerRadius = innerRadius;
    this.outerRadius = outerRadius;
    this.minAngle = minAngle;
    this.maxAngle = maxAngle;
  }

  double clamp(double angle, double limit) {
    while (angle > _maxAngle) {
      angle -= limit;
    }
    while (angle < _minAllowed) {
      angle += limit;
    }
    return angle;
  }

  void calculateNormals() {
    final minAngleRads = v.radians(_minAngle);
    final maxAngleRads = v.radians(_maxAngle);
    _minNormal = Maths.normalizePoint(sin(minAngleRads), -cos(minAngleRads), 1);
    _maxNormal = Maths.normalizePoint(-sin(maxAngleRads), cos(maxAngleRads), 1);
  }

  /// The radius of the inner edge of the disc.
  double get innerRadius {
    return _innerRadius;
  }

  set innerRadius(double value) {
    _innerRadius = value;
    _innerSq = _innerRadius * _innerRadius;
  }

  /// The radius of the outer edge of the disc.
  double get outerRadius {
    return _outerRadius;
  }

  set outerRadius(double value) {
    _outerRadius = value;
    _outerSq = _outerRadius * _outerRadius;
  }

  /// The minimum angle, in degrees, for points to be included in the zone.
  /// An angle of zero is horizontal and to the right. Positive angles are in a clockwise
  /// direction (towards the graphical y axis). Angles are converted to a value between 0
  /// and two times pi.
  double get minAngle {
    return _minAngle;
  }

  set minAngle(double value) {
    _minAngle = clamp(value, 360.0);
    calculateNormals();
  }

  /// The maximum angle, in degrees, for points to be included in the zone.
  /// An angle of zero is horizontal and to the right. Positive angles are in a clockwise
  /// direction (towards the graphical y axis). Angles are converted to a value between 0
  /// and two times pi.
  double get maxAngle {
    return _maxAngle;
  }

  set maxAngle(double value) {
    _maxAngle = value;
    while (_maxAngle > 360.0) {
      _maxAngle -= 360.0;
    }
    while (_maxAngle < 0) {
      _maxAngle += 360.0;
    }
    _minAllowed = _maxAngle - 360.0;
    _minAngle = clamp(_minAngle, 360.0);
    calculateNormals();
  }

  /// The contains method determines whether a point is inside the zone.
  /// This method is used by the initializers and actions that
  /// use the zone. Usually, it need not be called directly by the user.
  ///
  /// @param x The x coordinate of the location to test for.
  /// @param y The y coordinate of the location to test for.
  /// @return true if point is inside the zone, false if it is outside.
  bool contains(double x, double y) {
    x -= center.x;
    y -= center.y;
    double distSq = x * x + y * y;
    if (distSq > _outerSq || distSq < _innerSq) {
      return false;
    }
    double angle = atan2(y, x);
    angle = clamp(angle, TWOPI);
    return angle >= _minAngle;
  }

  /// The getLocation method returns a random point inside the zone.
  /// This method is used by the initializers and actions that
  /// use the zone. Usually, it need not be called directly by the user.
  ///
  /// @return a random point inside the zone.
  Point<double> getLocation() {
    double rand = Random().nextDouble();
    // Convert polar to cartesian
    final r = _innerRadius + (1 - rand * rand) * (_outerRadius - _innerRadius);
    final theta = _minAngle + Random().nextDouble() * (_maxAngle - _minAngle);
    return Maths.polarToCartesian(r, v.radians(theta)) + center;
  }

  /// The getArea method returns the size of the zone.
  /// This method is used by the MultiZone class. Usually,
  /// it need not be called directly by the user.
  ///
  /// @return a random point inside the zone.
  double getArea() {
    return (_outerSq - _innerSq) * (_maxAngle - _minAngle) * 0.5;
  }

  /// Manages collisions between a particle and the zone. The particle will collide with the edges of
  /// the disc sector defined for this zone, from inside or outside the disc. In the interests of speed,
  /// these collisions do not take account of the collisionRadius of the particle.
  ///
  /// @param particle The particle to be tested for collision with the zone.
  /// @param bounce The coefficient of restitution for the collision.
  ///
  /// @return Whether a collision occurred.
  bool collideParticle(Particle particle, [double bounce = 1]) {
    // This is approximate, since accurate calculations would be quite complex and thus time consuming

    double xNow = particle.x - center.x;
    double yNow = particle.y - center.y;
    double xThen = particle.previousX - center.x;
    double yThen = particle.previousY - center.y;
    bool insideNow = true;
    bool insideThen = true;

    double distThenSq = xThen * xThen + yThen * yThen;
    double distNowSq = xNow * xNow + yNow * yNow;
    if (distThenSq > _outerSq || distThenSq < _innerSq) {
      insideThen = false;
    }
    if (distNowSq > _outerSq || distNowSq < _innerSq) {
      insideNow = false;
    }
    if ((!insideNow) && (!insideThen)) {
      return false;
    }

    double angleThen = clamp(atan2(yThen, xThen), TWOPI);
    double angleNow = clamp(atan2(yNow, xNow), TWOPI);
    insideThen = insideThen && angleThen >= minAngle;
    insideNow = insideNow && angleNow >= _minAngle;
    if (insideNow == insideThen) {
      return false;
    }

    double adjustSpeed;
    double dotProduct = particle.velX * xNow + particle.velY * yNow;
    double factor;
    double normalSpeed;

    if (insideNow != null || insideNow == true) {
      if (distThenSq > _outerSq) {
        // bounce off outer radius
        adjustSpeed = (1 + bounce) * dotProduct / distNowSq;
        particle.velX -= adjustSpeed * xNow;
        particle.velY -= adjustSpeed * yNow;
      } else if (distThenSq < _innerSq) {
        // bounce off inner radius
        adjustSpeed = (1 + bounce) * dotProduct / distNowSq;
        particle.velX -= adjustSpeed * xNow;
        particle.velY -= adjustSpeed * yNow;
      }
      if (angleThen < _minAngle) {
        if (angleThen < (_minAllowed + _minAngle) / 2) {
          // bounce off max radius
          normalSpeed =
              _maxNormal.x * particle.velX + _maxNormal.y * particle.velY;
          factor = (1 + bounce) * normalSpeed;
          particle.velX -= factor * _maxNormal.x;
          particle.velY -= factor * _maxNormal.y;
        } else {
          // bounce off min radius
          normalSpeed =
              _minNormal.x * particle.velX + _minNormal.y * particle.velY;
          factor = (1 + bounce) * normalSpeed;
          particle.velX -= factor * _minNormal.x;
          particle.velY -= factor * _minNormal.y;
        }
      }
    } else // inside then
    {
      if (distNowSq > _outerSq) {
        // bounce off outer radius
        adjustSpeed = (1 + bounce) * dotProduct / distNowSq;
        particle.velX -= adjustSpeed * xNow;
        particle.velY -= adjustSpeed * yNow;
      } else if (distNowSq < _innerSq) {
        // bounce off inner radius
        adjustSpeed = (1 + bounce) * dotProduct / distNowSq;
        particle.velX -= adjustSpeed * xNow;
        particle.velY -= adjustSpeed * yNow;
      }
      if (angleNow < _minAngle) {
        if (angleNow < (_minAllowed + _minAngle) / 2) {
          // bounce off max radius
          normalSpeed =
              _maxNormal.x * particle.velX + _maxNormal.y * particle.velY;
          factor = (1 + bounce) * normalSpeed;
          particle.velX -= factor * _maxNormal.x;
          particle.velY -= factor * _maxNormal.y;
        } else {
          // bounce off min radius
          normalSpeed =
              _minNormal.x * particle.velX + _minNormal.y * particle.velY;
          factor = (1 + bounce) * normalSpeed;
          particle.velX -= factor * _minNormal.x;
          particle.velY -= factor * _minNormal.y;
        }
      }
    }
    particle.x = particle.previousX;
    particle.y = particle.previousY;

    return true;
  }
}
