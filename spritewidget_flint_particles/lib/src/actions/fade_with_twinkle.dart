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

/// The FadeWithTwinkle action adjusts the particle's alpha as it ages and also provides a twinkle effect by
/// toggling the alpha on and off. It uses the particle's energy level to decide what alpha to display.
///
/// Usually a particle's energy changes from 1 to 0 over its lifetime, but
/// this can be altered via the easing function set within the age action.
///
/// This action should be used in conjunction with the Age action.
///
/// This action has a priority of -5, so that this action executes after
/// color changes.
class FadeWithTwinkle extends Fade {
  double minDelay;
  double maxDelay;
  double offInterval;
  double onInterval;

  FadeWithTwinkle(
      {this.minDelay = 0,
      this.maxDelay = 0,
      this.offInterval = 1,
      this.onInterval = 1,
      double startAlpha = 1,
      double endAlpha = 0})
      : super(startAlpha, endAlpha);

  @override
  void update(Emitter emitter, Particle particle, double time) {
    _TwinkleData? data = particle.dictionary[this];
    if (data == null) {
      data = _TwinkleData()
        ..delay = this.minDelay +
            Random().nextDouble() * (this.maxDelay - this.minDelay);
      particle.dictionary[this] = data;
    }

    if (particle.age >= data.delay) {
      data.timeInState += time;
      // Twinkle is active
      if (data.isOn) {
        if (data.timeInState >= onInterval) {
          // Turn off
          data.isOn = false;
          data.timeInState = 0;
          final old = particle.color;
          particle.color = Color.fromARGB(0, old.red, old.green, old.blue);
        }
      } else {
        // Off
        if (data.timeInState >= offInterval) {
          // Turn on
          data.isOn = true;
          data.timeInState = 0;
        }
      }
    }

    if (data.isOn) {
      // Just set the fade value if particle is on
      super.update(emitter, particle, time);
    }
  }
}

class _TwinkleData {
  late double delay;
  bool isOn = true;
  double timeInState = 0;
}
