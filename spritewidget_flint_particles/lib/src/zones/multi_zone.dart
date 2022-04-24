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

/// The MultiZone zone defines a zone that combines other zones into one larger zone.
class MultiZone implements Zone {
  List<Zone> _zones = [];
  List<double> _areas = [];
  double _totalArea = 0;

  /// The constructor defines a MultiZone zone.
  MultiZone();

  /// The addZone method is used to add a zone into this MultiZone object.
  ///
  /// @param zone The zone you want to add.
  void addZone(Zone zone) {
    _zones.add(zone);
    double area = zone.getArea();
    _areas.add(area);
    _totalArea += area;
  }

  /// The removeZone method is used to remove a zone from this MultiZone object.
  ///
  /// @param zone The zone you want to add.
  void removeZone(Zone zone) {
    final idx = _zones.indexOf(zone);
    _totalArea -= _areas[idx];
    _areas.removeAt(idx);
    _zones.removeAt(idx);
  }

  bool contains(double x, double y) {
    int len = _zones.length;
    for (int i = 0; i < len; ++i) {
      if (_zones[i].contains(x, y)) {
        return true;
      }
    }
    return false;
  }

  Point<double> getLocation() {
    double selectZone = Random().nextDouble() * _totalArea;
    assert(_zones.isNotEmpty);
    int len = _zones.length;
    for (int i = 0; i < len; ++i) {
      if ((selectZone -= _areas[i]) <= 0) {
        return _zones[i].getLocation();
      }
    }

    return _zones[0].getLocation();
  }

  double getArea() {
    return _totalArea;
  }

  bool collideParticle(Particle particle, [double bounce = 1]) {
    bool collide = false;
    for (Zone zone in _zones) {
      collide = zone.collideParticle(particle, bounce) || collide;
    }
    return collide;
  }
}
