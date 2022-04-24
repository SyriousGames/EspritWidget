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

/// The FollowNode activity causes the emitter to follow
/// the position and rotation of a Node. The purpose is for the emitter
/// to emit particles from the location of the Node.
class FollowNode extends ActivityBase {
  /// The node that the emitter follows.
  Node node;

  /// The constructor creates a FollowNode activity for use by
  /// an emitter. To add a FollowNode to an emitter, use the
  /// emitter's addActvity method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addActivity()
  FollowNode(this.node);

  @override
  void update(Emitter emitter, double time) {
    final p = emitter
        .convertPointToNodeSpace(node.convertPointToBoxSpace(Offset.zero));
    emitter.position = p;
    emitter.rotation = node.rotation;
  }
}