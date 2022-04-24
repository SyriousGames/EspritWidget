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

/// The DiscZone zone defines a circular zone. The zone may
/// have a hole in the middle, like a doughnut.
class DiscZone implements Zone {
  /// The center of the disc.
  Point<double> center;

  /// The radius of the inner edge of the disc.
  late double _innerRadius;

  /// The radius of the outer edge of the disc.
  late double _outerRadius;
  late double _innerSq;
  late double _outerSq;

  static const double TWOPI = pi * 2;

  /// The constructor defines a DiscZone zone.
  ///
  /// @param center The centre of the disc.
  /// @param outerRadius The radius of the outer edge of the disc.
  /// @param innerRadius If set, this defines the radius of the inner
  /// edge of the disc. Points closer to the center than this inner radius
  /// are excluded from the zone. If this parameter is not set then all
  /// points inside the outer radius are included in the zone.
  DiscZone(this.center, [double outerRadius = 0, double innerRadius = 0]) {
    if (outerRadius < innerRadius) {
      throw Exception(
          'The outerRadius ($outerRadius) cannot be smaller than the innerRadius ($innerRadius)');
    }

    this.innerRadius = innerRadius;
    this.outerRadius = outerRadius;
  }

  double get innerRadius {
    return _innerRadius;
  }

  set innerRadius(double value) {
    _innerRadius = value;
    _innerSq = _innerRadius * _innerRadius;
  }

  double get outerRadius {
    return _outerRadius;
  }

  set outerRadius(double value) {
    _outerRadius = value;
    _outerSq = _outerRadius * _outerRadius;
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
    return distSq <= _outerSq && distSq >= _innerSq;
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
    final theta = Random().nextDouble() * TWOPI;
    return Maths.polarToCartesian(r, theta) + center;
  }

  /// The getArea method returns the size of the zone.
  /// This method is used by the MultiZone class. Usually,
  /// it need not be called directly by the user.
  ///
  /// @return a random point inside the zone.
  double getArea() {
    return pi * (_outerSq - _innerSq);
  }

  /// Manages collisions between a particle and the zone. The particle will collide with the edges of
  /// the disc defined for this zone, from inside or outside the disc.  The collisionRadius of the
  /// particle is used when calculating the collision.
  ///
  /// @param particle The particle to be tested for collision with the zone.
  /// @param bounce The coefficient of restitution for the collision.
  ///
  /// @return Whether a collision occured.
  bool collideParticle(Particle particle, [double bounce = 1]) {
    double outerLimit;
    double innerLimit;
    double outerLimitSq;
    double innerLimitSq;
    double distanceSq;
    double distance;
    double pdx;
    double pdy;
    double pDistanceSq;
    double adjustSpeed;
    double positionRatio;
    double epsilon = 0.001;
    double dx = particle.x - center.x;
    double dy = particle.y - center.y;
    double dotProduct = particle.velX * dx + particle.velY * dy;
    if (dotProduct < 0) // moving towards center
    {
      outerLimit = _outerRadius + particle.collisionRadius;
      if (dx.abs() > outerLimit) return false;
      if (dy.abs() > outerLimit) return false;
      distanceSq = dx * dx + dy * dy;
      outerLimitSq = outerLimit * outerLimit;
      if (distanceSq > outerLimitSq) return false;
      // Particle is inside outer circle

      pdx = particle.previousX - center.x;
      pdy = particle.previousY - center.y;
      pDistanceSq = pdx * pdx + pdy * pdy;
      if (pDistanceSq > outerLimitSq) {
        // particle was outside outer circle
        adjustSpeed = (1 + bounce) * dotProduct / distanceSq;
        particle.velX -= adjustSpeed * dx;
        particle.velY -= adjustSpeed * dy;
        distance = sqrt(distanceSq);
        positionRatio = (2 * outerLimit - distance) / distance + epsilon;
        particle.x = center.x + dx * positionRatio;
        particle.y = center.y + dy * positionRatio;
        return true;
      }

      if (_innerRadius != 0 && innerRadius != _outerRadius) {
        innerLimit = _innerRadius + particle.collisionRadius;
        if (dx.abs() > innerLimit) return false;
        if (dy.abs() > innerLimit) return false;
        innerLimitSq = innerLimit * innerLimit;
        if (distanceSq > innerLimitSq) return false;
        // Particle is inside inner circle

        if (pDistanceSq > innerLimitSq) {
          // particle was outside inner circle
          adjustSpeed = (1 + bounce) * dotProduct / distanceSq;
          particle.velX -= adjustSpeed * dx;
          particle.velY -= adjustSpeed * dy;
          distance = sqrt(distanceSq);
          positionRatio = (2 * innerLimit - distance) / distance + epsilon;
          particle.x = center.x + dx * positionRatio;
          particle.y = center.y + dy * positionRatio;
          return true;
        }
      }
      return false;
    } else // moving away from center
    {
      outerLimit = _outerRadius - particle.collisionRadius;
      pdx = particle.previousX - center.x;
      pdy = particle.previousY - center.y;
      if (pdx.abs() > outerLimit) return false;
      if (pdy.abs() > outerLimit) return false;
      pDistanceSq = pdx * pdx + pdy * pdy;
      outerLimitSq = outerLimit * outerLimit;
      if (pDistanceSq > outerLimitSq) return false;
      // particle was inside outer circle

      distanceSq = dx * dx + dy * dy;

      if (_innerRadius != 0 && innerRadius != _outerRadius) {
        innerLimit = _innerRadius - particle.collisionRadius;
        innerLimitSq = innerLimit * innerLimit;
        if (pDistanceSq < innerLimitSq && distanceSq >= innerLimitSq) {
          // particle was inside inner circle and is outside it
          adjustSpeed = (1 + bounce) * dotProduct / distanceSq;
          particle.velX -= adjustSpeed * dx;
          particle.velY -= adjustSpeed * dy;
          distance = sqrt(distanceSq);
          positionRatio = (2 * innerLimit - distance) / distance - epsilon;
          particle.x = center.x + dx * positionRatio;
          particle.y = center.y + dy * positionRatio;
          return true;
        }
      }

      if (distanceSq >= outerLimitSq) {
        // Particle is inside outer circle
        adjustSpeed = (1 + bounce) * dotProduct / distanceSq;
        particle.velX -= adjustSpeed * dx;
        particle.velY -= adjustSpeed * dy;
        distance = sqrt(distanceSq);
        positionRatio = (2 * outerLimit - distance) / distance - epsilon;
        particle.x = center.x + dx * positionRatio;
        particle.y = center.y + dy * positionRatio;
        return true;
      }
      return false;
    }
  }
}
