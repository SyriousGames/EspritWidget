/*
 * FLINT PARTICLE SYSTEM
 * .....................
 * 
 * This class is an update to Actionscript 3 of Robert Penner's Actionscript 2 easing equations
 * which are available under the following licence from http://www.robertpenner.com/easing/
 * 
 * TERMS OF USE - EASING EQUATIONS
 * 
 * Open source under the BSD License.
 * 
 * Copyright (c) 2001 Robert Penner
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are 
 * permitted provided that the following conditions are met: dynamic 
 * Redistributions of source code must retain the above copyright notice, this list of 
 * conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list 
 * of conditions and the following disclaimer in the documentation and/or other materials 
 * provided with the distribution.
 * Neither the name of the author nor the names of contributors may be used to endorse 
 * or promote products derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
 * SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * ==================================
 * 
 * Modifications: dynamic 
 * Author: Richard Lord
 * Copyright (c) Richard Lord 2008-2011
 * http://flintparticles.org
 * 
 * 
 * Used in the Flint Particle System which is licenced under the MIT license. As per the
 * original license for Robert Penner's classes, these specific classes are released under 
 * the BSD License.
 */

part of flint_particles;

/// Easing functions for use with aging of particles. Based on Robert Penner's easing functions.
class Elastic {
  static double easeIn(double t, double b, double c, double d,
      [double a = 0, double p = 0]) {
    if (t == 0) {
      return b;
    }
    if ((t /= d) == 1) {
      return b + c;
    }
    if (p == null || p == 0) {
      p = d * 0.3;
    }
    double s;
    if (a == null || a == 0 || a < c.abs()) {
      a = c;
      s = p * 0.25;
    } else {
      s = p / (2 * pi) * asin(c / a);
    }

    return -(a * pow(2, 10 * (--t)) * sin((t * d - s) * (2 * pi) / p)) + b;
  }

  static double easeOut(double t, double b, double c, double d,
      [double a = 0, double p = 0]) {
    if (t == 0) {
      return b;
    }
    if ((t /= d) == 1) {
      return b + c;
    }
    if (p == null || p == 0) {
      p = d * 0.3;
    }
    double s;
    if (a == null || a == 0 || a < c.abs()) {
      a = c;
      s = p * 0.25;
    } else {
      s = p / (2 * pi) * asin(c / a);
    }

    return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b;
  }

  static double easeInOut(double t, double b, double c, double d,
      [double a = 0, double p = 0]) {
    if (t == 0) {
      return b;
    }
    if ((t /= d * 0.5) == 2) {
      return b + c;
    }
    if (p == null || p == 0) {
      p = d * (0.3 * 1.5);
    }
    double s;
    if (a == null || a == 0 || a < c.abs()) {
      a = c;
      s = p * 0.25;
    } else {
      s = p / (2 * pi) * asin(c / a);
    }

    if (t < 1) {
      return -0.5 *
              (a * pow(2, 10 * (t -= 1)) * sin((t * d - s) * (2 * pi) / p)) +
          b;
    }

    return a * pow(2, -10 * (t -= 1)) * sin((t * d - s) * (2 * pi) / p) * 0.5 +
        c +
        b;
  }
}
