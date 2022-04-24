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

/// The TurnTowardsPoint action causes the particle to constantly adjust its
/// direction so that it travels towards a particular point.

class TurnTowardsPoint extends ActionBase {
  /// The x coordinate of the point that the particle turns towards.
  double x;

  /// The y coordinate of the point that the particle turns towards.
  double y;

  /// The strength of the turn action. Higher values produce a sharper turn.
  double power;

  /// The constructor creates a TurnTowardsPoint action for use by an emitter.
  /// To add a TurnTowardsPoint to all particles created by an emitter, use the
  /// emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param power The strength of the turn action. Higher values produce a sharper turn.
  /// @param x The x coordinate of the point towards which the particle turns.
  /// @param y The y coordinate of the point towards which the particle turns.
  TurnTowardsPoint([this.x = 0, this.y = 0, this.power = 0]);

  /// Calculates the direction to the focus point and turns the particle towards
  /// this direction.
  ///
  /// <p>This method is called by the emitter and need not be called by the
  /// user.</p>
  ///
  /// @param emitter The Emitter that created the particle.
  /// @param particle The particle to be updated.
  /// @param time The duration of the frame - used for time based updates.
  ///
  /// @see org.flintparticles.common.actions.Action#update()
  @override
  void update(Emitter emitter, Particle particle, double time) {
    Particle p = particle;
    double velLength = sqrt(p.velX * p.velX + p.velY * p.velY);
    double dx = p.velX / velLength;
    double dy = p.velY / velLength;
    double acc = power * time;
    double targetX = x - p.x;
    double targetY = y - p.y;
    double len = sqrt(targetX * targetX + targetY * targetY);
    if (len == 0) {
      return;
    }
    targetX /= len;
    targetY /= len;
    double dot = targetX * dx + targetY * dy;
    double perpX = targetX - dx * dot;
    double perpY = targetY - dy * dot;
    double factor = acc / sqrt(perpX * perpX + perpY * perpY);
    p.velX += perpX * factor;
    p.velY += perpY * factor;
    factor = velLength / sqrt(p.velX * p.velX + p.velY * p.velY);
    p.velX *= factor;
    p.velY *= factor;
  }
}
