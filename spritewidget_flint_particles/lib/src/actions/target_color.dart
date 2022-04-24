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

/// The TargetColor action adjusts the color of the particle towards a
/// target color. On every update the color of the particle moves a
/// little closer to the target color. The rate at which particles approach
/// the target is controlled by the rate property.
class TargetColor extends ActionBase {
  /// The target color.
  Color targetColor;

  /// Adjusts how quickly the particle reaches the target color.
  /// Larger numbers cause it to approach the target color more quickly.
  double rate;

  /// The constructor creates a TargetColor action for use by an emitter.
  /// To add a TargetColor to all particles created by an emitter, use the
  /// emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param targetColor The target color.
  /// @param rate Adjusts how quickly the particle reaches the target color.
  /// Larger numbers cause it to approach the target color more quickly.
  TargetColor(this.targetColor, [this.rate = 0.1]);

  /// Adjusts the color of the particle based on its current color, the target
  /// color and the time elapsed.
  ///
  /// <p>This method is called by the emitter and need not be called by the
  /// user</p>
  ///
  /// @param emitter The Emitter that created the particle.
  /// @param particle The particle to be updated.
  /// @param time The duration of the frame - used for time based updates.
  ///
  /// @see org.flintparticles.common.actions.Action#update()
  @override
  void update(Emitter emitter, Particle particle, double time) {
    double inv = rate * time;
    if (inv > 1) {
      inv = 1;
    }
    double ratio = 1 - inv;

    final currColor = particle.color;
    particle.color = Color.fromARGB(
        (currColor.alpha * ratio + targetColor.alpha * inv).round(),
        (currColor.red * ratio + targetColor.red * inv).round(),
        (currColor.green * ratio + targetColor.green * inv).round(),
        (currColor.blue * ratio + targetColor.blue * inv).round());
  }
}
