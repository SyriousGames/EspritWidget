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

/// The KeyDownAction Action uses another action. It applies the other action
/// to the particles only if a specified key is down.
///
/// @see org.flintparticles.common.actions.Action

// TODO ?
//class KeyDownAction extends ActionBase {
//  Action _action;
//  int _keyCode;
//  bool _isDown;
//  Stage _stage;
//
//  /// The constructor creates a KeyDownAction action for use by
//  /// an emitter. To add a KeyDownAction to all particles created by an emitter, use the
//  /// emitter's addAction method.
//  ///
//  /// @see org.flintparticles.emitters.Emitter#addAction()
//  ///
//  /// @param action The action to apply when the key is down.
//  /// @param keyCode The key code of the key that controls the action.
//  /// @param stage A reference to the stage.
//  KeyDownAction([Action action = null, int keyCode = 0, Stage stage = null]) {
//    _action = action;
//    _keyCode = keyCode;
//    _isDown = false;
//    _stage = stage;
//    createListeners();
//  }
//
//  void createListeners() {
//    if (_stage) {
//      _stage.addEventListener(
//          KeyboardEvent.KEY_DOWN, keyDownListener, false, 0, true);
//      _stage.addEventListener(
//          KeyboardEvent.KEY_UP, keyUpListener, false, 0, true);
//    }
//  }
//
//  void keyDownListener(KeyboardEvent ev) {
//    if (ev.keyCode == _keyCode) {
//      _isDown = true;
//    }
//  }
//
//  void keyUpListener(KeyboardEvent ev) {
//    if (ev.keyCode == _keyCode) {
//      _isDown = false;
//    }
//  }
//
//  /// A reference to the stage
//  Stage get stage {
//    return _stage;
//  }
//
//  void set stage(Stage value) {
//    _stage = value;
//    createListeners();
//  }
//
//  /// The action to apply when the key is down.
//  Action get action {
//    return _action;
//  }
//
//  void set action(Action value) {
//    _action = value;
//  }
//
//  /// The key code of the key that controls the action.
//  int get keyCode {
//    return _keyCode;
//  }
//
//  void set keyCode(int value) {
//    _keyCode = value;
//  }
//
//  /// Returns the default priority of the action that is applied.
//  ///
//  /// @see org.flintparticles.common.actions.Action#getDefaultPriority()
//  @override
//  int get priority {
//    return _action.priority;
//  }
//
//  @override
//  void set priority(int value) {
//    _action.priority = value;
//  }
//
//  /// Calls the addedToEmitter method of the action that is applied
//  ///
//  /// @param emitter The Emitter that the Action was added to.
//  ///
//  /// @see org.flintparticles.common.actions.Action#addedToEmitter()
//  @override
//  void addedToEmitter(Emitter emitter) {
//    _action.addedToEmitter(emitter);
//  }
//
//  /// Calls the removedFromEmitter method of the action that is applied
//  ///
//  /// @param emitter The Emitter that the Action was removed from.
//  ///
//  /// @see org.flintparticles.common.actions.Action#removedFromEmitter()
//  @override
//  void removedFromEmitter(Emitter emitter) {
//    _action.removedFromEmitter(emitter);
//  }
//
//  /// If the key is down, this method calls the update method of the
//  /// action that is applied.
//  ///
//  /// <p>This method is called by the emitter and need not be called by the
//  /// user</p>
//  ///
//  /// @param emitter The Emitter that created the particle.
//  /// @param particle The particle to be updated.
//  /// @param time The duration of the frame - used for time based updates.
//  ///
//  /// @see org.flintparticles.common.actions.Action#update()
//  @override
//  void update(Emitter emitter, Particle particle, double time) {
//    if (_isDown) {
//      _action.update(emitter, particle, time);
//    }
//  }
//}